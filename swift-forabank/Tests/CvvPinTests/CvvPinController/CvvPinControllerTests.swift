//
//  CvvPinControllerTests.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

import CvvPin
import XCTest

final class CvvPinControllerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotSendMessagesToSessionCodeLoader() {
        
        let sessionCodeLoader = makeSUT().sessionCodeLoader
        
        XCTAssertEqual(sessionCodeLoader.messages, [])
    }
    
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
    
    func test_init_shouldNotSendMessagesToPublicKeyAPIClient() {
        
        let publicKeyAPIClient = makeSUT().publicKeyAPIClient
        
        XCTAssertEqual(publicKeyAPIClient.messages, [])
    }
    
    // MARK: - auth
    
    func test_auth_shouldDeliverErrorOnSessionCodeLoaderError() {
        
        let (sut, sessionCodeLoader, _, _, _, _) = makeSUT()
        
        expect(sut, toAuthWith: [.failure(anyNSError(domain: "session"))]) {
            
            sessionCodeLoader.complete(with: .failure(anyNSError(domain: "session")))
        }
    }
    
    func test_auth_shouldDeliverErrorOnSecretRequestCryptoError() {
        
        let (sut, sessionCodeLoader, secretRequestCrypto, _, _, _) = makeSUT()
        
        expect(sut, toAuthWith: [.failure(anyNSError(domain: "secret request"))]) {
            
            sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
            secretRequestCrypto.complete(with: .failure(anyNSError(domain: "secret request")))
        }
    }
    
    func test_auth_shouldDeliverErrorOnPublicServerSessionKeyAPIClientError() {
        
        let (sut, sessionCodeLoader, secretRequestCrypto, publicServerSessionKeyAPIClient, _, _) = makeSUT()
        
        expect(sut, toAuthWith: [.failure(anyNSError(domain: "public server key"))]) {
            
            sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
            secretRequestCrypto.complete(with: .success(uniqueCryptoSecretRequest()))
            publicServerSessionKeyAPIClient.complete(with: .failure(anyNSError(domain: "public server key")))
        }
    }
    
    func test_auth_shouldDeliverErrorOnMakeSymmetricKeyError() {
        
        let (sut, sessionCodeLoader, secretRequestCrypto, publicServerSessionKeyAPIClient, symmetricCrypto, _) = makeSUT()
        
        expect(sut, toAuthWith: [.failure(anyNSError(domain: "symmetric key"))]) {
            
            sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
            secretRequestCrypto.complete(with: .success(uniqueCryptoSecretRequest()))
            publicServerSessionKeyAPIClient.complete(with: .success(uniquePublicServerSessionKeyPayload()))
            symmetricCrypto.complete(with: .failure(anyNSError(domain: "symmetric key")))
        }
    }
    
    func test_auth_shouldDeliverErrorOnSendPublicKeyError() {
        
        let (sut, sessionCodeLoader, secretRequestCrypto, publicServerSessionKeyAPIClient, symmetricCrypto, publicKeyAPIClient) = makeSUT()
        
        expect(sut, toAuthWith: [.failure(anyNSError(domain: "public key"))]) {
            
            sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
            secretRequestCrypto.complete(with: .success(uniqueCryptoSecretRequest()))
            publicServerSessionKeyAPIClient.complete(with: .success(uniquePublicServerSessionKeyPayload()))
            symmetricCrypto.complete(with: .success(uniqueSymmetricKey()))
            publicKeyAPIClient.complete(with: .failure(anyNSError(domain: "public key")))
        }
    }
    
    func test_auth_shouldDeliverAuthOnSuccess() {
        
        let (sut, sessionCodeLoader, secretRequestCrypto, publicServerSessionKeyAPIClient, symmetricCrypto, publicKeyAPIClient) = makeSUT()
        let sessionID = uniqueSessionID()
        let symmetricKey = uniqueSymmetricKey()
        let auth = CvvPinController.Auth(
            sessionID: sessionID,
            symmetricKey: symmetricKey
        )
        
        expect(sut, toAuthWith: [.success(auth)]) {
            
            sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
            secretRequestCrypto.complete(with: .success(uniqueCryptoSecretRequest()))
            publicServerSessionKeyAPIClient.complete(with: .success(uniquePublicServerSessionKeyPayload()))
            symmetricCrypto.complete(with: .success(uniqueSymmetricKey()))
            publicKeyAPIClient.complete(with: .success((sessionID, symmetricKey.apiSymmetricKey)))
        }
    }
    
    func test_auth_shouldNotReceiveSessionCodeResultAfterSUTInstanceHasBeenDeallocated() {
        
        let sessionCodeLoader = SessionCodeLoaderSpy()
        let secretRequestCrypto = SecretRequestCryptoSpy()
        let publicServerSessionKeyAPIClient = PublicServerSessionKeyAPIClientSpy()
        let symmetricCrypto = SymmetricCryptoSpy()
        let publicKeyAPIClient = PublicKeyAPIClientSpy()
        var sut: CvvPinController? = .init(
            sessionCodeLoader: sessionCodeLoader,
            secretRequestCrypto: secretRequestCrypto,
            publicServerSessionKeyAPIClient: publicServerSessionKeyAPIClient,
            symmetricCrypto: symmetricCrypto,
            publicKeyAPIClient: publicKeyAPIClient
        )
        var authResults = [CvvPinController.AuthResult]()
        
        sut?.auth { authResults.append($0) }
        sut = nil
        sessionCodeLoader.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(authResults.isEmpty)
    }
    
    func test_auth_shouldNotReceiveSecretRequestResultAfterSUTInstanceHasBeenDeallocated() {
        
        let sessionCodeLoader = SessionCodeLoaderSpy()
        let secretRequestCrypto = SecretRequestCryptoSpy()
        let publicServerSessionKeyAPIClient = PublicServerSessionKeyAPIClientSpy()
        let symmetricCrypto = SymmetricCryptoSpy()
        let publicKeyAPIClient = PublicKeyAPIClientSpy()
        var sut: CvvPinController? = .init(
            sessionCodeLoader: sessionCodeLoader,
            secretRequestCrypto: secretRequestCrypto,
            publicServerSessionKeyAPIClient: publicServerSessionKeyAPIClient,
            symmetricCrypto: symmetricCrypto,
            publicKeyAPIClient: publicKeyAPIClient
        )
        var authResults = [CvvPinController.AuthResult]()
        
        sut?.auth { authResults.append($0) }
        sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
        sut = nil
        secretRequestCrypto.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(authResults.isEmpty)
    }
    
    func test_auth_shouldNotReceivePublicServerSessionKeyResultAfterSUTInstanceHasBeenDeallocated() {
        
        let sessionCodeLoader = SessionCodeLoaderSpy()
        let secretRequestCrypto = SecretRequestCryptoSpy()
        let publicServerSessionKeyAPIClient = PublicServerSessionKeyAPIClientSpy()
        let symmetricCrypto = SymmetricCryptoSpy()
        let publicKeyAPIClient = PublicKeyAPIClientSpy()
        var sut: CvvPinController? = .init(
            sessionCodeLoader: sessionCodeLoader,
            secretRequestCrypto: secretRequestCrypto,
            publicServerSessionKeyAPIClient: publicServerSessionKeyAPIClient,
            symmetricCrypto: symmetricCrypto,
            publicKeyAPIClient: publicKeyAPIClient
        )
        var authResults = [CvvPinController.AuthResult]()
        
        sut?.auth { authResults.append($0) }
        sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
        secretRequestCrypto.complete(with: .success(uniqueCryptoSecretRequest()))
        sut = nil
        publicServerSessionKeyAPIClient.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(authResults.isEmpty)
    }
    
    func test_auth_shouldNotReceiveSymmetricKeyResultAfterSUTInstanceHasBeenDeallocated() {
        
        let sessionCodeLoader = SessionCodeLoaderSpy()
        let secretRequestCrypto = SecretRequestCryptoSpy()
        let publicServerSessionKeyAPIClient = PublicServerSessionKeyAPIClientSpy()
        let symmetricCrypto = SymmetricCryptoSpy()
        let publicKeyAPIClient = PublicKeyAPIClientSpy()
        var sut: CvvPinController? = .init(
            sessionCodeLoader: sessionCodeLoader,
            secretRequestCrypto: secretRequestCrypto,
            publicServerSessionKeyAPIClient: publicServerSessionKeyAPIClient,
            symmetricCrypto: symmetricCrypto,
            publicKeyAPIClient: publicKeyAPIClient
        )
        var authResults = [CvvPinController.AuthResult]()
        
        sut?.auth { authResults.append($0) }
        sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
        secretRequestCrypto.complete(with: .success(uniqueCryptoSecretRequest()))
        publicServerSessionKeyAPIClient.complete(with: .success(uniquePublicServerSessionKeyPayload()))
        sut = nil
        symmetricCrypto.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(authResults.isEmpty)
    }
    
    func test_auth_shouldNotReceivePublicKeyResultAfterSUTInstanceHasBeenDeallocated() {
        
        let sessionCodeLoader = SessionCodeLoaderSpy()
        let secretRequestCrypto = SecretRequestCryptoSpy()
        let publicServerSessionKeyAPIClient = PublicServerSessionKeyAPIClientSpy()
        let symmetricCrypto = SymmetricCryptoSpy()
        let publicKeyAPIClient = PublicKeyAPIClientSpy()
        var sut: CvvPinController? = .init(
            sessionCodeLoader: sessionCodeLoader,
            secretRequestCrypto: secretRequestCrypto,
            publicServerSessionKeyAPIClient: publicServerSessionKeyAPIClient,
            symmetricCrypto: symmetricCrypto,
            publicKeyAPIClient: publicKeyAPIClient
        )
        var authResults = [CvvPinController.AuthResult]()
        
        sut?.auth { authResults.append($0) }
        sessionCodeLoader.complete(with: .success(uniqueSessionCode()))
        secretRequestCrypto.complete(with: .success(uniqueCryptoSecretRequest()))
        publicServerSessionKeyAPIClient.complete(with: .success(uniquePublicServerSessionKeyPayload()))
        symmetricCrypto.complete(with: .success(uniqueSymmetricKey()))
        sut = nil
        publicKeyAPIClient.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(authResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: CvvPinController,
        sessionCodeLoader: SessionCodeLoaderSpy,
        secretRequestCrypto: SecretRequestCryptoSpy,
        publicServerSessionKeyAPIClient: PublicServerSessionKeyAPIClientSpy,
        symmetricCrypto: SymmetricCryptoSpy,
        publicKeyAPIClient: PublicKeyAPIClientSpy
    ) {
        let sessionCodeLoader = SessionCodeLoaderSpy()
        let secretRequestCrypto = SecretRequestCryptoSpy()
        let publicServerSessionKeyAPIClient = PublicServerSessionKeyAPIClientSpy()
        let symmetricCrypto = SymmetricCryptoSpy()
        let publicKeyAPIClient = PublicKeyAPIClientSpy()
        let sut = CvvPinController(
            sessionCodeLoader: sessionCodeLoader,
            secretRequestCrypto: secretRequestCrypto,
            publicServerSessionKeyAPIClient: publicServerSessionKeyAPIClient,
            symmetricCrypto: symmetricCrypto,
            publicKeyAPIClient: publicKeyAPIClient
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(sessionCodeLoader, file: file, line: line)
        trackForMemoryLeaks(secretRequestCrypto, file: file, line: line)
        trackForMemoryLeaks(publicServerSessionKeyAPIClient, file: file, line: line)
        trackForMemoryLeaks(symmetricCrypto, file: file, line: line)
        trackForMemoryLeaks(publicKeyAPIClient, file: file, line: line)
        
        return (sut, sessionCodeLoader, secretRequestCrypto, publicServerSessionKeyAPIClient, symmetricCrypto, publicKeyAPIClient)
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
    
    private final class PublicServerSessionKeyAPIClientSpy: PublicServerSessionKeyAPIClient {
        
        func get(
            _ request: SecretRequest,
            completion: @escaping Completion
        ) {
            messages.append(.getSecretRequest)
            getSecretRequestCompletions.append(completion)
        }
        
        private(set) var messages = [Message]()
        
        private(set) var getSecretRequestCompletions = [Completion]()
        
        func complete(
            with result: PublicServerSessionKeyAPIClient.Result,
            at index: Int = 0
        ) {
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

    private final class PublicKeyAPIClientSpy: PublicKeyAPIClient {
        
        func sendPublicKey(
            _ symmetricKey: APISymmetricKey,
            completion: @escaping SendPublicKeyCompletion
        ) {
            messages.append(.sendPublicKey)
            sendPublicKeyCompletions.append(completion)
        }
        
        private(set) var messages = [Message]()
        
        private(set) var sendPublicKeyCompletions = [SendPublicKeyCompletion]()
        
        func complete(
            with result: PublicKeyAPIClient.Result,
            at index: Int = 0
        ) {
            sendPublicKeyCompletions[index](result)
        }
        
        enum Message: Equatable {
            
            case sendPublicKey
        }
    }

    private func uniqueCryptoSecretRequest() -> CryptoSecretRequest {
        
        .init()
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
        _ sut: CvvPinController,
        toAuthWith expectedResults: [CvvPinController.AuthResult],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var authResults = [CvvPinController.AuthResult]()
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
