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
        
        let (_, authSpy, loadSessionSpy, showCVVRemoteService) = makeSUT()
        
        XCTAssertEqual(authSpy.callCount, 0)
        XCTAssertEqual(loadSessionSpy.callCount, 0)
        XCTAssertEqual(showCVVRemoteService.callCount, 0)
    }
    
    func test_showCVV_shouldDeliverErrorOnAuthActivationFailure() {
        
        let (sut, authSpy, _,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.activationFailure), on: {
            
            authSpy.complete(with: .failure(.activationFailure))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnAuthAuthenticationFailure() {
        
        let (sut, authSpy, _,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.authenticationFailure), on: {
            
            authSpy.complete(with: .failure(.authenticationFailure))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnLoadSessionFailure() throws {
        
        let sessionIDValue = UUID().uuidString
        let (sut, authSpy, loadSessionSpy, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(.makeJSONFailure)), on: {
            
            authSpy.complete(with: .success(.init(sessionIDValue: sessionIDValue)))
            loadSessionSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnShowCVVRemoteServiceCreateRequestFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let sessionIDValue = UUID().uuidString
        let sessionKeyValue = anyData()
        let (sut, authSpy, loadSessionSpy, showCVVRemoteService) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            authSpy.complete(with: .success(.init(sessionIDValue: sessionIDValue)))
            loadSessionSpy.complete(with: .success(.init(rsaKeyPair: keyPair, sessionKey: .init(sessionKeyValue: sessionKeyValue))))
            showCVVRemoteService.complete(with: .failure(.createRequest(anyError())))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnShowCVVRemoteServicePerformRequestFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let sessionIDValue = UUID().uuidString
        let sessionKeyValue = anyData()
        let (sut, authSpy, loadSessionSpy, showCVVRemoteService) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            authSpy.complete(with: .success(.init(sessionIDValue: sessionIDValue)))
            loadSessionSpy.complete(with: .success(.init(rsaKeyPair: keyPair, sessionKey: .init(sessionKeyValue: sessionKeyValue))))
            showCVVRemoteService.complete(with: .failure(.performRequest(anyError())))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnShowCVVRemoteServiceMapResponseFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let sessionIDValue = UUID().uuidString
        let sessionKeyValue = anyData()
        let (sut, authSpy, loadSessionSpy, showCVVRemoteService) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            authSpy.complete(with: .success(.init(sessionIDValue: sessionIDValue)))
            loadSessionSpy.complete(with: .success(.init(rsaKeyPair: keyPair, sessionKey: .init(sessionKeyValue: sessionKeyValue))))
            showCVVRemoteService.complete(with: .failure(.mapResponse(.connectivity)))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnSecondLoadSessionFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let sessionIDValue = UUID().uuidString
        let sessionKeyValue = anyData()
        let encryptedCVVValue = UUID().uuidString
        let (sut, authSpy, loadSessionSpy, showCVVRemoteService) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(.decryptionFailure)), on: {
            
            authSpy.complete(with: .success(.init(sessionIDValue: sessionIDValue)))
            loadSessionSpy.complete(with: .success(.init(rsaKeyPair: keyPair, sessionKey: .init(sessionKeyValue: sessionKeyValue))))
            showCVVRemoteService.complete(with: .success(.init(encryptedCVVValue: encryptedCVVValue)))
            loadSessionSpy.complete(with: .failure(anyNSError()), at: 1)
        })
    }
    
    func test_showCVV_shouldDeliverCVVOnSuccess() throws {
        
        let keyPair = try anyRSAKeyPair()
        let sessionIDValue = UUID().uuidString
        let sessionKeyValue = anyData()
        let cvv = "861"
        let encryptedCVVValue = try encrypt(cvv, with: keyPair.publicKey)
        let (sut, authSpy, loadSessionSpy, showCVVRemoteService) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(cvvValue: cvv)), on: {
            
            authSpy.complete(with: .success(.init(sessionIDValue: sessionIDValue)))
            loadSessionSpy.complete(with: .success(.init(rsaKeyPair: keyPair, sessionKey: .init(sessionKeyValue: sessionKeyValue))))
            showCVVRemoteService.complete(with: .success(.init(encryptedCVVValue: encryptedCVVValue)))
            loadSessionSpy.complete(with: .success(.init(rsaKeyPair: keyPair, sessionKey: .init(sessionKeyValue: sessionKeyValue))), at: 1)
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ShowCVVService
    private typealias AuthSpy = FetcherSpy<Void, SessionID, Services.AuthError>
    private typealias LoadSessionSpy = FetcherSpy<Void, Services.ShowCVVSession, Error>
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
        authSpy: AuthSpy,
        loadSessionSpy: LoadSessionSpy,
        showCVVRemoteService: ShowCVVRemoteService
    ) {
        let authSpy = AuthSpy()
        let loadSessionSpy = LoadSessionSpy()
        let showCVVRemoteService = ShowCVVRemoteService()
        let cvvPINCrypto = LiveExtraLoggingCVVPINCrypto(
            transportKey: transportKeyResult.get,
            processingKey: processingKeyResult.get,
            log: { _,_,_ in }
        )
        let cvvPINJSONMaker = LiveCVVPINJSONMaker(crypto: cvvPINCrypto)
        
        let sut = Services.makeShowCVVService(
            auth: authSpy.fetch(completion:),
            loadSession: loadSessionSpy.fetch(completion:),
            showCVVRemoteService: showCVVRemoteService,
            cvvPINCrypto: cvvPINCrypto,
            cvvPINJSONMaker: cvvPINJSONMaker
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(authSpy, file: file, line: line)
        trackForMemoryLeaks(loadSessionSpy, file: file, line: line)
        trackForMemoryLeaks(showCVVRemoteService, file: file, line: line)
        
        return (sut, authSpy, loadSessionSpy, showCVVRemoteService)
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
                
            case let (
                .success(expectedCVV),
                .success(receivedCVV)
            ):
                XCTAssertNoDiff(expectedCVV.equatable, receivedCVV.equatable, file: file, line: line)
                
            default:
                XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func encrypt(
        _ string: String,
        with publicKey: RSADomain.PublicKey
    ) throws -> String {
        
        let encrypted = try ForaCrypto.Crypto.encrypt(
            data: .init(string.utf8),
            withPublicKey: publicKey.key,
            algorithm: .rsaEncryptionPKCS1
        )
        
        return encrypted.base64EncodedString()
    }
}

private extension ShowCVVService.CVV {
    
    var equatable: EquatableCVV {
        
        .init(cvvValue: cvvValue)
    }
    
    struct EquatableCVV: Equatable {
        
        let cvvValue: String
    }
}
