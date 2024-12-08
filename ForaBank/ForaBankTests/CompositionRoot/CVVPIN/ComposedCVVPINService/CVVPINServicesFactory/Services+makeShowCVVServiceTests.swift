//
//  Services+makeShowCVVServiceTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 10.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import VortexCrypto
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
        
        let (sut, authSpy, loadSessionSpy, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(.makeJSONFailure)), on: {
            
            authSpy.complete(with: anySuccess())
            loadSessionSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnMakeJSONFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let (sut, authSpy, loadSessionSpy, _) = makeSUT(
            makeShowCVVSecretJSONResult: .failure(anyError()))
        
        expect(sut, toDeliver: .failure(.serviceError(.makeJSONFailure)), on: {
            
            authSpy.complete(with: anySuccess())
            loadSessionSpy.complete(with: anySuccess(keyPair: keyPair))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnShowCVVRemoteServiceCreateRequestFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let (sut, authSpy, loadSessionSpy, showCVVRemoteService) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            authSpy.complete(with: anySuccess())
            loadSessionSpy.complete(with: anySuccess(keyPair: keyPair))
            showCVVRemoteService.complete(with: .failure(.createRequest(anyError())))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnShowCVVRemoteServicePerformRequestFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let (sut, authSpy, loadSessionSpy, showCVVRemoteService) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            authSpy.complete(with: anySuccess())
            loadSessionSpy.complete(with: anySuccess(keyPair: keyPair))
            showCVVRemoteService.complete(with: .failure(.performRequest(anyError())))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnShowCVVRemoteServiceMapResponseFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let (sut, authSpy, loadSessionSpy, showCVVRemoteService) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            authSpy.complete(with: anySuccess())
            loadSessionSpy.complete(with: anySuccess(keyPair: keyPair))
            showCVVRemoteService.complete(with: .failure(.mapResponse(.connectivity)))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnSecondLoadSessionFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let encryptedCVVValue = UUID().uuidString
        let (sut, authSpy, loadSessionSpy, showCVVRemoteService) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(.decryptionFailure)), on: {
            
            authSpy.complete(with: anySuccess())
            loadSessionSpy.complete(with: anySuccess(keyPair: keyPair))
            showCVVRemoteService.complete(with: anySuccess())
            loadSessionSpy.complete(with: .failure(anyNSError()), at: 1)
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnDecryptFailure() throws {
        
        let keyPair = try anyRSAKeyPair()
        let (sut, authSpy, loadSessionSpy, showCVVRemoteService) = makeSUT(
            decryptStringResult: .failure(anyError())
        )
        
        expect(sut, toDeliver: .failure(.serviceError(.decryptionFailure)), on: {
            
            authSpy.complete(with: anySuccess())
            loadSessionSpy.complete(with: anySuccess(keyPair: keyPair))
            showCVVRemoteService.complete(with: anySuccess())
            loadSessionSpy.complete(with: anySuccess(keyPair: keyPair), at: 1)
        })
    }
    
    func test_showCVV_shouldDeliverCVVOnSuccess() throws {
        
        let keyPair = try anyRSAKeyPair()
        let cvv = "861"
        let (sut, authSpy, loadSessionSpy, showCVVRemoteService) = makeSUT(
            decryptStringResult: .success(cvv)
        )
        
        expect(sut, toDeliver: .success(.init(cvvValue: cvv)), on: {
            
            authSpy.complete(with: anySuccess())
            loadSessionSpy.complete(with: anySuccess(keyPair: keyPair))
            showCVVRemoteService.complete(with: anySuccess())
            loadSessionSpy.complete(with: anySuccess(keyPair: keyPair), at: 1)
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ShowCVVService
    private typealias AuthSpy = Spy<Void, SessionID, Services.AuthError>
    private typealias LoadSessionSpy = Spy<Void, Services.ShowCVVSession, Error>
    private typealias ShowCVVRemoteService = Spy<(SessionID, Data), ShowCVVService.EncryptedCVV, MappingRemoteServiceError<ShowCVVService.APIError>>
    private typealias TransportKey = LiveExtraLoggingCVVPINCrypto.TransportKey
    private typealias ProcessingKey = LiveExtraLoggingCVVPINCrypto.ProcessingKey
    
    private func makeSUT(
        transportKeyResult: Result<TransportKey, Error> = anyTransportKeyResult(),
        processingKeyResult: Result<ProcessingKey, Error> = anyProcessingKeyResult(),
        makeShowCVVSecretJSONResult: Result<Data, Error> = .success(anyData()),
        decryptStringResult: Result<String, Error> = .success(UUID().uuidString),
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
        
        let sut = Services.makeShowCVVService(
            auth: authSpy.fetch(completion:),
            loadSession: loadSessionSpy.fetch(completion:),
            showCVVRemoteService: showCVVRemoteService,
            decryptString: { _,_ in try decryptStringResult.get() },
            makeShowCVVSecretJSON: { _,_,_,_ in try makeShowCVVSecretJSONResult.get() }
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
}

private extension ShowCVVService.CVV {
    
    var equatable: EquatableCVV {
        
        .init(cvvValue: cvvValue)
    }
    
    struct EquatableCVV: Equatable {
        
        let cvvValue: String
    }
}

private func anySuccess(
    sessionIDValue: String = UUID().uuidString
) -> Result<SessionID, Services.AuthError> {
    
    .success(.init(sessionIDValue: sessionIDValue))
}

private func anySuccess(
    keyPair: RSADomain.KeyPair,
    sessionKeyValue: Data = anyData()
) -> Result<Services.ShowCVVSession, Error> {
    
    .success(.init(
        rsaKeyPair: keyPair,
        sessionKey: .init(sessionKeyValue: sessionKeyValue)
    ))
}

private func anySuccess(
    encryptedCVVValue: String = UUID().uuidString
) -> Result<ShowCVVService.EncryptedCVV, MappingRemoteServiceError<ShowCVVService.APIError>> {
    
    .success(.init(encryptedCVVValue: encryptedCVVValue))
}

