//
//  Services+makeChangePINServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

final class Services_makeChangePINServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, authSpy, loadSessionSpy, changePINRemoteSpy, confirmRemoteSpy, decryptSpy) = makeSUT()
        
        XCTAssertEqual(authSpy.callCount, 0)
        XCTAssertEqual(loadSessionSpy.callCount, 0)
        XCTAssertEqual(changePINRemoteSpy.callCount, 0)
        XCTAssertEqual(confirmRemoteSpy.callCount, 0)
        XCTAssertEqual(decryptSpy.callCount, 0)
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnAuthActivationFailure() {
        
        let (sut, authSpy, _,_,_,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.activationFailure), on: {
            
            authSpy.complete(with: .failure(.activationFailure))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnAuthAuthenticationFailure() {
        
        let (sut, authSpy, _,_,_,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.authenticationFailure), on: {
            
            authSpy.complete(with: .failure(.authenticationFailure))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnConfirmRemoteCreateRequestFailure() {
        
        let sessionIDValue = UUID().uuidString
        let (sut, authSpy, _,_, confirmRemoteSpy,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            authSpy.complete(with: .success(.init(value: sessionIDValue)))
            confirmRemoteSpy.complete(with: .failure(.createRequest(anyError())))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnConfirmRemotePerformRequestFailure() {
        
        let sessionIDValue = UUID().uuidString
        let (sut, authSpy, _,_, confirmRemoteSpy,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            authSpy.complete(with: .success(.init(value: sessionIDValue)))
            confirmRemoteSpy.complete(with: .failure(.createRequest(anyError())))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnConfirmRemoteMapReponseInvalidFailure() {
        
        let sessionIDValue = UUID().uuidString
        let statusCode = 500
        let invalidData = anyData()
        let (sut, authSpy, _,_, confirmRemoteSpy,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.invalid(statusCode: statusCode, data: invalidData)), on: {
            
            authSpy.complete(with: .success(.init(value: sessionIDValue)))
            confirmRemoteSpy.complete(with: .failure(.mapResponse(.invalid(statusCode: statusCode, data: invalidData))))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnConfirmRemoteMapReponseNetworkFailure() {
        
        let sessionIDValue = UUID().uuidString
        let (sut, authSpy, _,_, confirmRemoteSpy,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            authSpy.complete(with: .success(.init(value: sessionIDValue)))
            confirmRemoteSpy.complete(with: .failure(.mapResponse(.network)))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnConfirmRemoteMapReponseServerFailure() {
        
        let sessionIDValue = UUID().uuidString
        let statusCode = 500
        let errorMessage = "Server Failure"
        let (sut, authSpy, _,_, confirmRemoteSpy,_) = makeSUT()
        
        expect(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)), on: {
            
            authSpy.complete(with: .success(.init(value: sessionIDValue)))
            confirmRemoteSpy.complete(with: .failure(.mapResponse(.server(statusCode: statusCode, errorMessage: errorMessage))))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnEventIDDecryptFailure() {
        
        let (sut, authSpy, _,_, confirmRemoteSpy, decryptSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(.decryptionFailure)), on: {
            
            authSpy.complete(with: .success(.init(value: UUID().uuidString)))
            confirmRemoteSpy.complete(with: .success(.init(eventID: UUID().uuidString, phone: "+7..8945")))
            decryptSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnPhoneDecryptFailure() {
        
        let (sut, authSpy, _,_, confirmRemoteSpy, decryptSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.serviceError(.decryptionFailure)), on: {
            
            authSpy.complete(with: .success(.init(value: UUID().uuidString)))
            confirmRemoteSpy.complete(with: .success(.init(eventID: UUID().uuidString, phone: "+7..8945")))
            decryptSpy.complete(with: .success(UUID().uuidString))
            decryptSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverValueOnSuccess() {
        
        let sessionIDValue = UUID().uuidString
        let eventIDValue = UUID().uuidString
        let phone = "+7..8945"
        let (sut, authSpy, _,_, confirmRemoteSpy, decryptSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(otpEventID: .init(eventIDValue: eventIDValue), phone: phone)), on: {
            
            authSpy.complete(with: .success(.init(value: sessionIDValue)))
            confirmRemoteSpy.complete(with: .success(.init(eventID: eventIDValue, phone: phone)))
            decryptSpy.complete(with: .success(eventIDValue))
            decryptSpy.complete(with: .success(phone), at: 1)
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ChangePINService
    private typealias AuthSpy = FetcherSpy<Void, SessionID, Services.AuthError>
    private typealias LoadSessionSpy = FetcherSpy<Void, Services.ChangePINSession, Error>
    private typealias DecryptSpy = FetcherSpy<String, String, Error>
    private typealias ChangePINRemoteSpy = FetcherSpy<(SessionID, Data), Void, MappingRemoteServiceError<ChangePINService.ChangePINAPIError>>
    private typealias ConfirmRemoteSpy = FetcherSpy<SessionID, ChangePINService.EncryptedConfirmResponse, MappingRemoteServiceError<ChangePINService.ConfirmAPIError>>
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
        changePINRemoteSpy: ChangePINRemoteSpy,
        confirmRemoteSpy: ConfirmRemoteSpy,
        decryptSpy: DecryptSpy
    ) {
        let authSpy = AuthSpy()
        let loadSessionSpy = LoadSessionSpy()
        let decryptSpy = DecryptSpy()
        let changePINRemoteSpy = ChangePINRemoteSpy()
        let confirmRemoteSpy = ConfirmRemoteSpy()
        
        let cvvPINCrypto = LiveExtraLoggingCVVPINCrypto(
            transportKey: transportKeyResult.get,
            processingKey: processingKeyResult.get,
            log: { _,_,_ in }
        )
        let cvvPINJSONMaker = LiveCVVPINJSONMaker(crypto: cvvPINCrypto)
        
        let sut = Services.makeChangePINService(
            auth: authSpy.fetch(completion:),
            loadSession: loadSessionSpy.fetch(completion:),
            changePINRemoteService: changePINRemoteSpy,
            confirmChangePINRemoteService: confirmRemoteSpy,
            publicRSAKeyDecrypt: decryptSpy.fetch(_:completion:),
            cvvPINJSONMaker: cvvPINJSONMaker
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(authSpy, file: file, line: line)
        trackForMemoryLeaks(loadSessionSpy, file: file, line: line)
        trackForMemoryLeaks(changePINRemoteSpy, file: file, line: line)
        trackForMemoryLeaks(confirmRemoteSpy, file: file, line: line)
        trackForMemoryLeaks(decryptSpy, file: file, line: line)
        
        return (sut, authSpy, loadSessionSpy, changePINRemoteSpy, confirmRemoteSpy, decryptSpy)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResult: SUT.GetPINConfirmationCodeResult,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.getPINConfirmationCode { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case (.failure(.activationFailure), .failure(.activationFailure)),
                (.failure(.authenticationFailure), .failure(.authenticationFailure)),
                (.failure(.network), .failure(.network)):
                break
                
            case let (
                .failure(.invalid(receivedStatusCode, receivedInvalidData)),
                .failure(.invalid(expectedStatusCode, expectedInvalidData))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedInvalidData, expectedInvalidData, file: file, line: line)
                
            case let (
                .failure(.retry(receivedStatusCode, receivedInvalidData, receivedRetryAttempts)),
                .failure(.retry(expectedStatusCode, expectedInvalidData, expectedRetryAttempts))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedInvalidData, expectedInvalidData, file: file, line: line)
                XCTAssertNoDiff(receivedRetryAttempts, expectedRetryAttempts, file: file, line: line)
                
            case let (
                .failure(.server(receivedStatusCode, receivedErrorMessage)),
                .failure(.server(expectedStatusCode, expectedErrorMessage))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedErrorMessage, expectedErrorMessage, file: file, line: line)
                
            case let (
                .failure(.serviceError(receivedServiceError)),
                .failure(.serviceError(expectedServiceError))
            ):
                switch (receivedServiceError, expectedServiceError) {
                case (.checkSessionFailure, .checkSessionFailure),
                    (.decryptionFailure, .decryptionFailure),
                    (.makeJSONFailure, .makeJSONFailure):
                    break
                    
                default:
                    XCTFail("\nExpected \(expectedServiceError), but got \(receivedServiceError) instead.", file: file, line: line)
                }
                
            case let (
                .success(receivedSuccess),
                .success(expectedSuccess)
            ):
                XCTAssertNoDiff(receivedSuccess.equatable, expectedSuccess.equatable, file: file, line: line)
                
            default:
                XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

private extension ChangePINService
    .ConfirmResponse {
        
        var equatable: EquatableConfirmResponse {
            
            .init(otpEventIDValue: otpEventID.eventIDValue, phone: phone)
        }
        
        struct EquatableConfirmResponse: Equatable {
            
            let otpEventIDValue: String
            let phone: String
        }
    }
