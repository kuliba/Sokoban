//
//  CvvPinServiceTests.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

import CvvPin
import XCTest

final class CvvPinServiceTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotSendMessagesToSessionCodeLoader() {
        
        let sessionCodeLoader = makeSUT().sessionCodeLoader
        
        XCTAssertEqual(sessionCodeLoader.messages, [])
    }
    
    func test_init_shouldNotSendMessagesToSymmetricCrypto() {
        
        let symmetricKeyService = makeSUT().symmetricKeyService
        
        XCTAssertEqual(symmetricKeyService.messages, [])
    }
    
    func test_init_shouldNotSendMessagesToPublicKeyAPIClient() {
        
        let bindPublicKeySpy = makeSUT().bindPublicKeySpy
        
        XCTAssertEqual(bindPublicKeySpy.messages, [])
    }
    
    // MARK: - auth
    
    func test_auth_shouldDeliverErrorOnSessionCodeLoaderError() {
        
        let (sut, sessionCodeLoader, _, _) = makeSUT()
        
        expect(sut, toAuthWith: [.failure(anyNSError(domain: "session"))]) {
            
            sessionCodeLoader.complete(with: .failure(anyNSError(domain: "session")))
        }
    }
    
    func test_auth_shouldDeliverErrorOnMakeSymmetricKeyError() {
        
        let (sut, sessionCodeLoader, symmetricKeyService, _) = makeSUT()
        
        expect(sut, toAuthWith: [.failure(anyNSError(domain: "symmetric key"))]) {
            
            sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
            symmetricKeyService.complete(with: .failure(anyNSError(domain: "symmetric key")))
        }
    }
    
    func test_auth_shouldDeliverErrorOnBindPublicKeyError() {
        
        let (sut, sessionCodeLoader, symmetricKeyService, bindPublicKeySpy) = makeSUT()
        
        expect(sut, toAuthWith: [.failure(anyNSError(domain: "public key"))]) {
            
            sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
            symmetricKeyService.complete(with: .success(uniqueSymmetricKey()))
            bindPublicKeySpy.complete(with: .failure(anyNSError(domain: "public key")))
        }
    }
    
    func test_auth_shouldDeliverAuthOnSuccess() {
        
        let (sut, sessionCodeLoader, symmetricKeyService, bindPublicKeySpy) = makeSUT()
        let sessionID = uniqueSessionID()
        let symmetricKey = uniqueSymmetricKey()
        let auth = CvvPinService.Auth(
            sessionID: sessionID,
            symmetricKey: symmetricKey
        )
        
        expect(sut, toAuthWith: [.success(auth)]) {
            
            sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
            symmetricKeyService.complete(with: .success(uniqueSymmetricKey()))
            bindPublicKeySpy.complete(with: .success((sessionID, symmetricKey.apiSymmetricKey)))
        }
    }
    
    func test_auth_shouldNotReceiveSessionCodeResultAfterSUTInstanceHasBeenDeallocated() {
        
        let sessionCodeLoader = SessionCodeLoaderSpy()
        let symmetricKeyService = SymmetricKeyServiceSpy()
        let bindPublicKeySpy = BindPublicKeySpy()
        var sut: CvvPinService? = .init(
            getProcessingSessionCode: sessionCodeLoader.load,
            symmetricKeyService: symmetricKeyService,
            bindPublicKey: bindPublicKeySpy.perform
        )
        var authResults = [CvvPinService.AuthResult]()
        
        sut?.auth { authResults.append($0) }
        sut = nil
        sessionCodeLoader.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(authResults.isEmpty)
    }
    
    func test_auth_shouldNotReceiveSymmetricKeyResultAfterSUTInstanceHasBeenDeallocated() {
        
        let sessionCodeLoader = SessionCodeLoaderSpy()
        let symmetricKeyService = SymmetricKeyServiceSpy()
        let bindPublicKeySpy = BindPublicKeySpy()
        var sut: CvvPinService? = .init(
            getProcessingSessionCode: sessionCodeLoader.load,
            symmetricKeyService: symmetricKeyService,
            bindPublicKey: bindPublicKeySpy.perform
        )
        var authResults = [CvvPinService.AuthResult]()
        
        sut?.auth { authResults.append($0) }
        sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
        sut = nil
        symmetricKeyService.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(authResults.isEmpty)
    }
    
    func test_auth_shouldNotReceivePublicKeyResultAfterSUTInstanceHasBeenDeallocated() {
        
        let sessionCodeLoader = SessionCodeLoaderSpy()
        let symmetricKeyService = SymmetricKeyServiceSpy()
        let bindPublicKeySpy = BindPublicKeySpy()
        var sut: CvvPinService? = .init(
            getProcessingSessionCode: sessionCodeLoader.load,
            symmetricKeyService: symmetricKeyService,
            bindPublicKey: bindPublicKeySpy.perform
        )
        var authResults = [CvvPinService.AuthResult]()
        
        sut?.auth { authResults.append($0) }
        sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
        symmetricKeyService.complete(with: .success(uniqueSymmetricKey()))
        sut = nil
        bindPublicKeySpy.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(authResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: CvvPinService,
        sessionCodeLoader: SessionCodeLoaderSpy,
        symmetricKeyService: SymmetricKeyServiceSpy,
        bindPublicKeySpy: BindPublicKeySpy
    ) {
        let sessionCodeLoader = SessionCodeLoaderSpy()
        let symmetricKeyService = SymmetricKeyServiceSpy()
        let bindPublicKeySpy = BindPublicKeySpy()
        let sut = CvvPinService(
            getProcessingSessionCode: sessionCodeLoader.load,
            symmetricKeyService: symmetricKeyService,
            bindPublicKey: bindPublicKeySpy.perform
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(sessionCodeLoader, file: file, line: line)
        trackForMemoryLeaks(symmetricKeyService, file: file, line: line)
        trackForMemoryLeaks(bindPublicKeySpy, file: file, line: line)
        
        return (sut, sessionCodeLoader, symmetricKeyService, bindPublicKeySpy)
    }
    
    private final class SessionCodeLoaderSpy: SessionCodeLoader {
        
        func load(completion: @escaping LoadCompletion) {
            
            messages.append(.load)
            loadSessionCodeCompletions.append(completion)
        }
        
        private(set) var messages = [Message]()
        
        private(set) var loadSessionCodeCompletions = [LoadCompletion]()
        
        func complete(
            with result: SessionCodeLoader.Result,
            at index: Int = 0
        ) {
            loadSessionCodeCompletions[index](result)
        }
        
        enum Message: Equatable {
            
            case load
        }
    }
    
    private final class SymmetricKeyServiceSpy: SymmetricKeyService {
        
        func makeSymmetricKey(
            with sessionCode: CryptoSessionCode,
            completion: @escaping SymmetricKeyCompletion
        ) {
            messages.append(.makeSymmetricKey)
            makeSymmetricKeyCompletions.append(completion)
        }
        
        private(set) var messages = [Message]()
        
        private(set) var makeSymmetricKeyCompletions = [SymmetricKeyCompletion]()
        
        func complete(
            with result: SymmetricCrypto.Result,
            at index: Int = 0
        ) {
            makeSymmetricKeyCompletions[index](result)
        }
        
        enum Message: Equatable {
            
            case makeSymmetricKey
        }
    }
    
    private final class BindPublicKeySpy {
        
        typealias Request = APISymmetricKey
        typealias Response = (SessionID, APISymmetricKey)
        typealias Result = Swift.Result<Response, Error>
        typealias Completion = (Result) -> Void
        
        func perform(
            _ request: Request,
            completion: @escaping Completion
        ) {
            messages.append(.sendPublicKey)
            sendPublicKeyCompletions.append(completion)
        }
        
        private(set) var messages = [Message]()
        
        private(set) var sendPublicKeyCompletions = [Completion]()
        
        func complete(with result: Result, at index: Int = 0) {
            
            sendPublicKeyCompletions[index](result)
        }
        
        enum Message: Equatable {
            
            case sendPublicKey
        }
    }
    
    private func uniqueSymmetricKey() -> SymmetricKey {
        
        .init(value: UUID().uuidString)
    }
    
    private func uniqueSessionID() -> SessionID {
        
        .init(value: UUID().uuidString)
    }
    
    private func expect(
        _ sut: CvvPinService,
        toAuthWith expectedResults: [CvvPinService.AuthResult],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var authResults = [CvvPinService.AuthResult]()
        let exp = expectation(description: "wait for auth")
        
        sut.auth {
            authResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(authResults.count, expectedResults.count, "Expected \(expectedResults.count) results, got \(authResults.count) instead.", file: file, line: line)
        
        zip(authResults, expectedResults).enumerated().forEach { index, element in
            
            switch element {
            case let (.failure(received as NSError?), .failure(expected as NSError?)):
                XCTAssertNoDiff(received, expected, file: file, line: line)
                
            case let (.success(received), .success(expected)):
                XCTAssertNoDiff(received, expected, file: file, line: line)
                
            default:
                XCTFail("Expected \(element.1), got \(element.0) instead.", file: file, line: line)
            }
        }
    }
}
