//
//  Services+makeShowCVVServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import ForaCrypto
import XCTest

final class Services_makeShowCVVServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, rsaKeyPairLoader, sessionIDLoader, sessionKeyLoader, authWithPublicKeyService, showCVVRemoteService) = makeSUT()
        
        XCTAssertEqual(rsaKeyPairLoader.callCount, 0)
        XCTAssertEqual(sessionIDLoader.callCount, 0)
        XCTAssertEqual(sessionKeyLoader.callCount, 0)
        XCTAssertEqual(authWithPublicKeyService.callCount, 0)
        XCTAssertEqual(showCVVRemoteService.callCount, 0)
    }
    
    func test_showCVV_shouldDeliverErrorOnLoadRSAKeyPairFailure() {
        
        let (sut, rsaKeyPairLoader, _, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.activationFailure), on: {
            
            rsaKeyPairLoader.completeLoad(with: .failure(anyError()))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnSecondLoadRSAKeyFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let sessionIDValue = UUID().uuidString
        let (sut, rsaKeyPairLoader, sessionIDLoader, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(.makeJSONFailure)), on: {
            
            rsaKeyPairLoader.completeLoad(with: .success(keyPair))
            sessionIDLoader.completeLoad(with: .success(.init(value: sessionIDValue)))
            rsaKeyPairLoader.completeLoad(with: .failure(anyError()), at: 1)
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnLoadSessionKeyFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let sessionIDValue = UUID().uuidString
        let (sut, rsaKeyPairLoader, sessionIDLoader, sessionKeyLoader, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(.makeJSONFailure)), on: {
            
            rsaKeyPairLoader.completeLoad(with: .success(keyPair))
            sessionIDLoader.completeLoad(with: .success(.init(value: sessionIDValue)))
            rsaKeyPairLoader.completeLoad(with: .success(keyPair), at: 1)
            sessionKeyLoader.completeLoad(with: .failure(anyError()))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnShowCVVRemoteServiceCreateRequestFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let sessionIDValue = UUID().uuidString
        let sessionKeyValue = anyData()
        let (sut, rsaKeyPairLoader, sessionIDLoader, sessionKeyLoader, _, showCVVRemoteService) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            rsaKeyPairLoader.completeLoad(with: .success(keyPair))
            sessionIDLoader.completeLoad(with: .success(.init(value: sessionIDValue)))
            rsaKeyPairLoader.completeLoad(with: .success(keyPair), at: 1)
            sessionKeyLoader.completeLoad(with: .success(.init(sessionKeyValue: sessionKeyValue)))
            showCVVRemoteService.complete(with: .failure(.createRequest(anyError())))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnShowCVVRemoteServicePerformRequestFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let sessionIDValue = UUID().uuidString
        let sessionKeyValue = anyData()
        let (sut, rsaKeyPairLoader, sessionIDLoader, sessionKeyLoader, _, showCVVRemoteService) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            rsaKeyPairLoader.completeLoad(with: .success(keyPair))
            sessionIDLoader.completeLoad(with: .success(.init(value: sessionIDValue)))
            rsaKeyPairLoader.completeLoad(with: .success(keyPair), at: 1)
            sessionKeyLoader.completeLoad(with: .success(.init(sessionKeyValue: sessionKeyValue)))
            showCVVRemoteService.complete(with: .failure(.performRequest(anyError())))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnShowCVVRemoteServiceMapResponseFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let sessionIDValue = UUID().uuidString
        let sessionKeyValue = anyData()
        let (sut, rsaKeyPairLoader, sessionIDLoader, sessionKeyLoader, _, showCVVRemoteService) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            rsaKeyPairLoader.completeLoad(with: .success(keyPair))
            sessionIDLoader.completeLoad(with: .success(.init(value: sessionIDValue)))
            rsaKeyPairLoader.completeLoad(with: .success(keyPair), at: 1)
            sessionKeyLoader.completeLoad(with: .success(.init(sessionKeyValue: sessionKeyValue)))
            showCVVRemoteService.complete(with: .failure(.mapResponse(.connectivity)))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnLoadSessionIDFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let statusCode = 500
        let invalidData = anyData()
        let (sut, rsaKeyPairLoader, sessionIDLoader, _, authWithPublicKeyService, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.authenticationFailure), on: {
            
            rsaKeyPairLoader.completeLoad(with: .success(keyPair))
            sessionIDLoader.completeLoad(with: .failure(anyError()))
            authWithPublicKeyService.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }

    // MARK: - Helpers
    
    private typealias SUT = ShowCVVService
    private typealias RSAKeyPairLoader = LoaderSpy<RSADomain.KeyPair>
    private typealias SessionIDLoader = LoaderSpy<SessionID>
    private typealias SessionKeyLoader = LoaderSpy<SessionKey>
    private typealias AuthWithPublicKeyService = FetcherSpy<AuthenticateWithPublicKeyService.Payload, AuthenticateWithPublicKeyService.Success, AuthenticateWithPublicKeyService.Failure>
    private typealias ShowCVVRemoteService = FetcherSpy<(SessionID, Data), ShowCVVService.EncryptedCVV, MappingRemoteServiceError<ShowCVVService.APIError>>
    private typealias TransportKey = LiveExtraLoggingCVVPINCrypto.TransportKey
    private typealias ProcessingKey = LiveExtraLoggingCVVPINCrypto.ProcessingKey
    
    private func makeSUT(
        transportKeyResult: Result<TransportKey, Error> = anyTransportKeyResult(),
        processingKeyResult: Result<ProcessingKey, Error> = anyProcessingKeyResult(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        rsaKeyPairLoader: RSAKeyPairLoader,
        sessionIDLoader: SessionIDLoader,
        sessionKeyLoader: SessionKeyLoader,
        authWithPublicKeyService: AuthWithPublicKeyService,
        showCVVRemoteService: ShowCVVRemoteService
    ) {
        let rsaKeyPairLoader = RSAKeyPairLoader()
        let sessionIDLoader = SessionIDLoader()
        let sessionKeyLoader = SessionKeyLoader()
        let authWithPublicKeyService = AuthWithPublicKeyService()
        let showCVVRemoteService = ShowCVVRemoteService()
        let cvvPINCrypto = LiveExtraLoggingCVVPINCrypto(
            transportKey: transportKeyResult.get,
            processingKey: processingKeyResult.get,
            log: { _,_,_ in }
        )
        let cvvPINJSONMaker = LiveCVVPINJSONMaker(crypto: cvvPINCrypto)
        
        let sut = Services.makeShowCVVService(
            rsaKeyPairLoader: rsaKeyPairLoader,
            sessionIDLoader: sessionIDLoader,
            sessionKeyLoader: sessionKeyLoader,
            authWithPublicKeyService: authWithPublicKeyService,
            showCVVRemoteService: showCVVRemoteService,
            cvvPINCrypto: cvvPINCrypto,
            cvvPINJSONMaker: cvvPINJSONMaker
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(rsaKeyPairLoader, file: file, line: line)
        trackForMemoryLeaks(sessionIDLoader, file: file, line: line)
        trackForMemoryLeaks(sessionKeyLoader, file: file, line: line)
        trackForMemoryLeaks(authWithPublicKeyService, file: file, line: line)
        trackForMemoryLeaks(showCVVRemoteService, file: file, line: line)
        
        return (sut, rsaKeyPairLoader, sessionIDLoader, sessionKeyLoader, authWithPublicKeyService, showCVVRemoteService)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResult: ShowCVVService.Result,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.showCVV(cardID: anyCardID()) { receivedResult in
            
            switch (expectedResult, receivedResult) {
            case (.failure(.activationFailure), .failure(.activationFailure)),
                (.failure(.authenticationFailure), .failure(.authenticationFailure)),
                (.failure(.network), .failure(.network)):
                break
                
            case let (
                .failure(.serviceError(expectedServiceError)),
                .failure(.serviceError(receivedServiceError))
            ):
                switch (expectedServiceError, receivedServiceError) {
                case (.decryptionFailure, .decryptionFailure),
                    (.makeJSONFailure, .makeJSONFailure):
                    break
                    
                default:
                    XCTFail("\nExpected \(expectedServiceError), but got \(receivedServiceError) instead.", file: file, line: line)
                }
                
            default:
                XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

private func anyTransportKeyResult() ->
Result<LiveExtraLoggingCVVPINCrypto.TransportKey, Error> {
    
    Result {
        
        try ForaCrypto.Crypto.generateKeyPair(keyType: .rsa, keySize: .bits4096)
    }
    .map(\.publicKey)
    .map(LiveExtraLoggingCVVPINCrypto.TransportKey.init(key:))
}

private func anyProcessingKeyResult() ->
Result<LiveExtraLoggingCVVPINCrypto.ProcessingKey, Error> {
    
    Result {
        
        try ForaCrypto.Crypto.generateKeyPair(
            keyType: .rsa,
            keySize: .bits4096
        )
    }
    .map(\.publicKey)
    .map(LiveExtraLoggingCVVPINCrypto.ProcessingKey.init(key:))
}

private func anyRSAKeyPair() throws -> RSADomain.KeyPair {
    
    let (publicKey, privateKey) = try ForaCrypto.Crypto.generateKeyPair(
        keyType: .rsa,
        keySize: .bits4096
    )

    return (privateKey: .init(key: privateKey), publicKey: .init(key: publicKey))
}
