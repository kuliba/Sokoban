//
//  ComposedKeyExchangeServiceTests.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

import CryptoKit
import CvvPin
import XCTest

final class ComposedKeyExchangeServiceTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotSendMessagesToMakeSecretRequest() {
        
        let makeSecretRequestSpy = makeSUT().makeSecretRequestSpy
        
        XCTAssertEqual(makeSecretRequestSpy.messages, [])
    }
    
    func test_init_shouldNotSendMessagesToFormSessionKey() {
        
        let formSessionKeySpy = makeSUT().formSessionKeySpy
        
        XCTAssertEqual(formSessionKeySpy.callCount, 0)
    }
    
    func test_init_shouldNotSendMessagesToExtractSharedSecret() {
        
        let extractSharedSecretSpy = makeSUT().extractSharedSecretSpy
        
        XCTAssertEqual(extractSharedSecretSpy.callCount, 0)
    }
    
    // MARK: - makeSymmetricKey
    
    func test_makeSymmetricKey_shouldDeliverErrorOnMissingCompletions() {
        
        let error = anyNSError(domain: "secret request")
        let (sut, _, _, _) = makeSUT([
            .failure(error)
        ])
        
        expect(sut, exchangeKeyResult: [.failure(error)], on: {})
    }
    
    func test_makeSymmetricKey_shouldDeliverErrorOnFormSessionKeyError() {
        
        let formSessionKeyError = anyNSError(domain: "public server key")
        let (sut, _, formSessionKeySpy, _) = makeSUT([
            .success(uniqueCryptoSecretRequest())
        ])
        
        expect(sut, exchangeKeyResult: [
            .failure(formSessionKeyError)
        ]) {
            formSessionKeySpy.complete(with: .failure(formSessionKeyError))
        }
    }
    
    func test_makeSymmetricKey_shouldDeliverErrorOnExtractSharedSecretError() {
        
        let extractSharedSecretError = anyNSError(domain: "symmetric key")
        let (sut, _, formSessionKeySpy, extractSharedSecretSpy) = makeSUT([
            .success(uniqueCryptoSecretRequest())
        ])
        
        expect(sut, exchangeKeyResult: [
            .failure(extractSharedSecretError)
        ]) {
            formSessionKeySpy.complete(with: .success(uniquePublicServerSessionKeyPayload()))
            extractSharedSecretSpy.complete(with: .failure(extractSharedSecretError))
        }
    }
    
    func test_makeSymmetricKey_shouldDeliverKeyExchangeOnSuccess() {
        
        let data = "some data".data(using: .utf8)!
        let (sut, _, formSessionKey, extractSharedSecretSpy) = makeSUT([
            .success(uniqueCryptoSecretRequest())
        ])
        
        expect(sut, exchangeKeyResult: [
            .success(data)
        ]) {
            formSessionKey.complete(with: .success(uniquePublicServerSessionKeyPayload()))
            extractSharedSecretSpy.complete(with: .success(data))
        }
    }
    
    func test_makeSymmetricKey_shouldNotReceivePublicServerSessionKeyResultAfterSUTInstanceHasBeenDeallocated() {
        
        let makeSecretRequestSpy = MakeSecretRequestSpy(stub: [
            .success(uniqueCryptoSecretRequest())
        ])
        let formSessionKeySpy = FormSessionKeySpy()
        let extractSharedSecretSpy = ExtractSharedSecretSpy()
        var sut: KeyExchangeService? = .init(
            makeSecretRequest: makeSecretRequestSpy.make,
            formSessionKey: formSessionKeySpy.process,
            extractSharedSecret: extractSharedSecretSpy.process
        )
        var makeSymmetricKeyResults = [KeyExchangeDomain.Result]()
        let sessionCode = uniqueCryptoSessionCode()
        
        sut?.exchangeKey(with: sessionCode) { makeSymmetricKeyResults.append($0) }
        sut = nil
        formSessionKeySpy.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(makeSymmetricKeyResults.isEmpty)
    }
    
    func test_makeSymmetricKey_shouldNotReceiveSymmetricKeyResultAfterSUTInstanceHasBeenDeallocated() {
        
        let makeSecretRequestSpy = MakeSecretRequestSpy(stub: [
            .success(uniqueCryptoSecretRequest())
        ])
        let formSessionKeySpy = FormSessionKeySpy()
        let extractSharedSecretSpy = ExtractSharedSecretSpy()
        var sut: KeyExchangeService? = .init(
            makeSecretRequest: makeSecretRequestSpy.make,
            formSessionKey: formSessionKeySpy.process,
            extractSharedSecret: extractSharedSecretSpy.process
        )
        var makeSymmetricKeyResults = [KeyExchangeDomain.Result]()
        let sessionCode = uniqueCryptoSessionCode()
        
        sut?.exchangeKey(with: sessionCode) { makeSymmetricKeyResults.append($0) }
        formSessionKeySpy.complete(with: .success(uniquePublicServerSessionKeyPayload()))
        sut = nil
        extractSharedSecretSpy.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(makeSymmetricKeyResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias FormSessionKeySpy = RemoteServiceSpy<FormSessionKeyDomain.PublicServerSessionKeyPayload, Error, FormSessionKeyDomain.Request>
    private typealias ExtractSharedSecretSpy = RemoteServiceSpy<Data, Error, String>
    typealias MakeSecretRequestSpy = StubbedSpyOf<KeyExchangeDomain.SessionCode, KeyExchangeDomain.SecretRequest>
    
    private typealias SecretRequestResult = Result<KeyExchangeDomain.SecretRequest, Error>
    
    private func makeSUT(
        _ stubbedResults: [SecretRequestResult] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: KeyExchangeService,
        makeSecretRequestSpy: MakeSecretRequestSpy,
        formSessionKeySpy: FormSessionKeySpy,
        extractSharedSecretSpy: ExtractSharedSecretSpy
    ) {
        let makeSecretRequestSpy = MakeSecretRequestSpy(stub: stubbedResults)
        let formSessionKeySpy = FormSessionKeySpy()
        let extractSharedSecretSpy = ExtractSharedSecretSpy()
        let sut = KeyExchangeService(
            makeSecretRequest: makeSecretRequestSpy.make,
            formSessionKey: formSessionKeySpy.process,
            extractSharedSecret: extractSharedSecretSpy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(makeSecretRequestSpy, file: file, line: line)
        trackForMemoryLeaks(formSessionKeySpy, file: file, line: line)
        trackForMemoryLeaks(extractSharedSecretSpy, file: file, line: line)
        
        return (sut, makeSecretRequestSpy, formSessionKeySpy, extractSharedSecretSpy)
    }
    
    private func uniqueCryptoSessionCode(
    ) -> KeyExchangeDomain.SessionCode {
        
        .init(value: UUID().uuidString)
    }
    
    private func uniqueCryptoSecretRequest(
    ) -> KeyExchangeDomain.SecretRequest {
        
        .init(
            code: .init(value: UUID().uuidString),
            data: anyData()
        )
    }
    
    private func uniquePublicServerSessionKeyPayload(
    ) -> FormSessionKeyDomain.Response {
        
        .init(
            publicServerSessionKey: uniquePublicServerSessionKey(),
            eventID: uniqueEventID(),
            sessionTTL: 123
        )
    }
    
    private func uniquePublicServerSessionKey(
    ) -> FormSessionKeyDomain.Response.PublicServerSessionKey {
        
        .init(value: UUID().uuidString)
    }
    
    private func uniqueEventID(
    ) -> FormSessionKeyDomain.Response.EventID {
        
        .init(value: UUID().uuidString)
    }
    
    private func uniqueSymmetricKey() -> SymmetricKey {
        
        .init(size: .bits256)
    }
    
    private func expect(
        _ sut: KeyExchangeService,
        exchangeKeyResult expectedResults: [SharedSecretDomain.Result],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var extractSharedSecretResults = [SharedSecretDomain.Result]()
        let exp = expectation(description: "wait for makeSymmetricKey")
        let sessionCode = uniqueCryptoSessionCode()
        
        sut.exchangeKey(with: sessionCode) {
            
            extractSharedSecretResults.append($0.map(\.sharedSecret))
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(extractSharedSecretResults.count, expectedResults.count, "Expected \(expectedResults.count) results, got \(extractSharedSecretResults.count) instead.", file: file, line: line)
        
        zip(extractSharedSecretResults, expectedResults).enumerated().forEach { index, element in
            
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
