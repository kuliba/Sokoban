//
//  ComposedSymmetricKeyMakerTests.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

import CvvPin
import XCTest

final class ComposedSymmetricKeyMakerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotSendMessagesToSecretRequest() {
        
        let secretRequestCrypto = makeSUT().secretRequestCrypto
        
        XCTAssertEqual(secretRequestCrypto.messages, [])
    }
    
    func test_init_shouldNotSendMessagesToPublicServerSessionKeyAPIClient() {
        
        let symmetricCrypto = makeSUT().publicServerSessionKeyAPIClient
        
        XCTAssertEqual(symmetricCrypto.messages, [])
    }
    
    func test_init_shouldNotSendMessagesToSymmetricCrypto() {
        
        let symmetricCrypto = makeSUT().symmetricCrypto
        
        XCTAssertEqual(symmetricCrypto.messages, [])
    }
    
    // MARK: - makeSymmetricKey
    
    func test_makeSymmetricKey_shouldDeliverErrorOnSecretRequestCryptoError() {
        
        let (sut, secretRequestCrypto, _, _) = makeSUT()
        
        expect(sut, toMakeSymmetricKey: [.failure(anyNSError(domain: "secret request"))]) {
            
            secretRequestCrypto.complete(with: .failure(anyNSError(domain: "secret request")))
        }
    }
    
    func test_makeSymmetricKey_shouldDeliverErrorOnPublicServerSessionKeyAPIClientError() {
        
        let (sut, secretRequestCrypto, publicServerSessionKeyAPIClient, _) = makeSUT()
        
        expect(sut, toMakeSymmetricKey: [.failure(anyNSError(domain: "public server key"))]) {
            
            secretRequestCrypto.complete(with: .success(uniqueCryptoSecretRequest()))
            publicServerSessionKeyAPIClient.complete(with: .failure(anyNSError(domain: "public server key")))
        }
    }
    
    func test_makeSymmetricKey_shouldDeliverErrorOnMakeSymmetricKeyError() {
        
        let (sut, secretRequestCrypto, publicServerSessionKeyAPIClient, symmetricCrypto) = makeSUT()
        
        expect(sut, toMakeSymmetricKey: [.failure(anyNSError(domain: "symmetric key"))]) {
            
            secretRequestCrypto.complete(with: .success(uniqueCryptoSecretRequest()))
            publicServerSessionKeyAPIClient.complete(with: .success(uniquePublicServerSessionKeyPayload()))
            symmetricCrypto.complete(with: .failure(anyNSError(domain: "symmetric key")))
        }
    }
    
    func test_makeSymmetricKey_shouldDeliverAuthOnSuccess() {
        
        let (sut, secretRequestCrypto, publicServerSessionKeyAPIClient, symmetricCrypto) = makeSUT()
        let symmetricKey = uniqueSymmetricKey()
        
        expect(sut, toMakeSymmetricKey: [.success(symmetricKey)]) {
            
            secretRequestCrypto.complete(with: .success(uniqueCryptoSecretRequest()))
            publicServerSessionKeyAPIClient.complete(with: .success(uniquePublicServerSessionKeyPayload()))
            symmetricCrypto.complete(with: .success(symmetricKey))
        }
    }
    
    func test_makeSymmetricKey_shouldNotReceiveSecretRequestResultAfterSUTInstanceHasBeenDeallocated() {
        
        let secretRequestCrypto = SecretRequestCryptoSpy()
        let publicServerSessionKeyAPIClient = PublicServerSessionKeyAPIClientSpy()
        let symmetricCrypto = SymmetricCryptoSpy()
        var sut: ComposedSymmetricKeyMaker? = .init(
            secretRequestCrypto: secretRequestCrypto,
            publicServerSessionKeyAPIClient: publicServerSessionKeyAPIClient,
            symmetricCrypto: symmetricCrypto
        )
        var makeSymmetricKeyResults = [ComposedSymmetricKeyMaker.Result]()
        let sessionCode = uniqueCryptoSessionCode()
        
        sut?.makeSymmetricKey(with: sessionCode) { makeSymmetricKeyResults.append($0) }
        sut = nil
        secretRequestCrypto.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(makeSymmetricKeyResults.isEmpty)
    }
    
    func test_makeSymmetricKey_shouldNotReceivePublicServerSessionKeyResultAfterSUTInstanceHasBeenDeallocated() {
        
        let secretRequestCrypto = SecretRequestCryptoSpy()
        let publicServerSessionKeyAPIClient = PublicServerSessionKeyAPIClientSpy()
        let symmetricCrypto = SymmetricCryptoSpy()
        var sut: ComposedSymmetricKeyMaker? = .init(
            secretRequestCrypto: secretRequestCrypto,
            publicServerSessionKeyAPIClient: publicServerSessionKeyAPIClient,
            symmetricCrypto: symmetricCrypto
        )
        var makeSymmetricKeyResults = [ComposedSymmetricKeyMaker.Result]()
        let sessionCode = uniqueCryptoSessionCode()
        
        sut?.makeSymmetricKey(with: sessionCode) { makeSymmetricKeyResults.append($0) }
        secretRequestCrypto.complete(with: .success(uniqueCryptoSecretRequest()))
        sut = nil
        publicServerSessionKeyAPIClient.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(makeSymmetricKeyResults.isEmpty)
    }
    
    func test_makeSymmetricKey_shouldNotReceiveSymmetricKeyResultAfterSUTInstanceHasBeenDeallocated() {
        
        let secretRequestCrypto = SecretRequestCryptoSpy()
        let publicServerSessionKeyAPIClient = PublicServerSessionKeyAPIClientSpy()
        let symmetricCrypto = SymmetricCryptoSpy()
        var sut: ComposedSymmetricKeyMaker? = .init(
            secretRequestCrypto: secretRequestCrypto,
            publicServerSessionKeyAPIClient: publicServerSessionKeyAPIClient,
            symmetricCrypto: symmetricCrypto
        )
        var makeSymmetricKeyResults = [ComposedSymmetricKeyMaker.Result]()
        let sessionCode = uniqueCryptoSessionCode()
        
        sut?.makeSymmetricKey(with: sessionCode) { makeSymmetricKeyResults.append($0) }
        secretRequestCrypto.complete(with: .success(uniqueCryptoSecretRequest()))
        publicServerSessionKeyAPIClient.complete(with: .success(uniquePublicServerSessionKeyPayload()))
        sut = nil
        symmetricCrypto.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(makeSymmetricKeyResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SymmetricKeyMaker,
        secretRequestCrypto: SecretRequestCryptoSpy,
        publicServerSessionKeyAPIClient: PublicServerSessionKeyAPIClientSpy,
        symmetricCrypto: SymmetricCryptoSpy
    ) {
        let secretRequestCrypto = SecretRequestCryptoSpy()
        let publicServerSessionKeyAPIClient = PublicServerSessionKeyAPIClientSpy()
        let symmetricCrypto = SymmetricCryptoSpy()
        let sut = ComposedSymmetricKeyMaker(
            secretRequestCrypto: secretRequestCrypto,
            publicServerSessionKeyAPIClient: publicServerSessionKeyAPIClient,
            symmetricCrypto: symmetricCrypto
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(secretRequestCrypto, file: file, line: line)
        trackForMemoryLeaks(publicServerSessionKeyAPIClient, file: file, line: line)
        trackForMemoryLeaks(symmetricCrypto, file: file, line: line)
        
        return (sut, secretRequestCrypto, publicServerSessionKeyAPIClient, symmetricCrypto)
    }
    
    private final class SecretRequestCryptoSpy: SecretRequestCrypto {
        
        func makeSecretRequest(
            sessionCode: CryptoSessionCode,
            completion: @escaping Completion
        ) {
            messages.append(.makeSecretRequest)
            makeSecretRequestCompletions.append(completion)
        }
        
        private(set) var messages = [Message]()
        
        private(set) var makeSecretRequestCompletions = [Completion]()
        
        func complete(
            with result: SecretRequestCrypto.Result,
            at index: Int = 0
        ) {
            makeSecretRequestCompletions[index](result)
        }
        
        enum Message: Equatable {
            
            case makeSecretRequest
        }
    }
    
    private final class PublicServerSessionKeyAPIClientSpy: CryptoAPIClient {
        
        typealias Request = SecretRequest
        typealias Response = PublicServerSessionKeyPayload
        typealias Result = Swift.Result<Response, Error>
        typealias Completion = (Result) -> Void
        
        func get(
            _ request: Request,
            completion: @escaping Completion
        ) {
            messages.append(.getSecretRequest)
            getSecretRequestCompletions.append(completion)
        }
        
        private(set) var messages = [Message]()
        
        private(set) var getSecretRequestCompletions = [Completion]()
        
        func complete(with result: Result, at index: Int = 0) {
            
            getSecretRequestCompletions[index](result)
        }
        
        enum Message: Equatable {
            
            case getSecretRequest
        }
    }

    private final class SymmetricCryptoSpy: SymmetricCrypto {
        
        func makeSymmetricKey(
            with payload: Payload,
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
    
    private func uniqueCryptoSessionCode() -> CryptoSessionCode {
        
        .init(value: UUID().uuidString)
    }

    private func uniqueCryptoSecretRequest() -> CryptoSecretRequest {
        
        .init(
            code: .init(value: UUID().uuidString),
            data: UUID().uuidString.data(using: .utf8)!
        )
    }
    
    private func uniquePublicServerSessionKeyPayload(
    ) -> PublicServerSessionKeyPayload {
        
        .init(
            publicServerSessionKey: uniquePublicServerSessionKey(),
            eventID: uniqueEventID(),
            sessionTTL: 123
        )
    }
    
    private func uniquePublicServerSessionKey(
    ) -> PublicServerSessionKeyPayload.PublicServerSessionKey {
        
        .init(value: UUID().uuidString)
    }
    
    private func uniqueEventID(
    ) -> PublicServerSessionKeyPayload.EventID {
        
        .init(value: UUID().uuidString)
    }
    
    private func uniqueSymmetricKey() -> SymmetricKey {
        
        .init(value: UUID().uuidString)
    }
    
    private func uniqueSessionID() -> SessionID {
        
        .init(value: UUID().uuidString)
    }
    
    private func expect(
        _ sut: SymmetricKeyMaker,
        toMakeSymmetricKey expectedResults: [ComposedSymmetricKeyMaker.Result],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var makeSymmetricKeyResults = [ComposedSymmetricKeyMaker.Result]()
        let exp = expectation(description: "wait for makeSymmetricKey")
        let sessionCode = uniqueCryptoSessionCode()
        
        sut.makeSymmetricKey(with: sessionCode) { makeSymmetricKeyResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(makeSymmetricKeyResults.count, expectedResults.count, "Expected \(expectedResults.count) results, got \(makeSymmetricKeyResults.count) instead.", file: file, line: line)
        
        zip(makeSymmetricKeyResults, expectedResults).enumerated().forEach { index, element in
            
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
