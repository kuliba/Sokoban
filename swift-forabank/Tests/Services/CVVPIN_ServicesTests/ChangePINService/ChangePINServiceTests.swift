//
//  ChangePINServiceTests.swift
//  
//
//  Created by Igor Malyarov on 04.11.2023.
//

import CVVPIN_Services
import XCTest

final class ChangePINServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, authenticateSpy, confirmProcessSpy, decryptSpy, makeJSONSpy, changePINProcessSpy) = makeSUT()
        
        XCTAssertNoDiff(authenticateSpy.callCount, 0)
        XCTAssertNoDiff(decryptSpy.callCount, 0)
        XCTAssertNoDiff(confirmProcessSpy.callCount, 0)
        XCTAssertNoDiff(makeJSONSpy.callCount, 0)
        XCTAssertNoDiff(changePINProcessSpy.callCount, 0)
    }
    
    // MARK: - getPINConfirmationCode
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnAuthenticateActivationFailure() {
        
        let (sut, authenticateSpy, _, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.activationFailure), on: {
            
            authenticateSpy.complete(with: .failure(.activationFailure))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnAuthenticateAuthenticationFailure() {
        
        let (sut, authenticateSpy, _, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.authenticationFailure), on: {
            
            authenticateSpy.complete(with: .failure(.authenticationFailure))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnConfirmProcessInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, authenticateSpy, confirmProcessSpy, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.invalid(statusCode: statusCode, data: invalidData)), on: {
            authenticateSpy.complete(with: anySuccess())
            confirmProcessSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnConfirmProcessNetworkFailure() {
        
        let (sut, authenticateSpy, confirmProcessSpy, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.network), on: {
            
            authenticateSpy.complete(with: anySuccess())
            confirmProcessSpy.complete(with: .failure(.network))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnConfirmProcessServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Confirmation Error"
        let (sut, authenticateSpy, confirmProcessSpy, _, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)), on: {
            authenticateSpy.complete(with: anySuccess())
            confirmProcessSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnEventIDDecryptFailure() {
        
        let (sut, authenticateSpy, confirmProcessSpy, decryptSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.decryptionFailure), on: {
            authenticateSpy.complete(with: anySuccess())
            confirmProcessSpy.complete(with: anySuccess())
            decryptSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverErrorOnPhoneDecryptFailure() {
        
        let otpEventID = UUID().uuidString
        let (sut, authenticateSpy, confirmProcessSpy, decryptSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: .failure(.decryptionFailure), on: {
            authenticateSpy.complete(with: anySuccess())
            confirmProcessSpy.complete(with: anySuccess())
            decryptSpy.complete(with: .success(otpEventID))
            decryptSpy.complete(with: .failure(anyError()), at: 1)
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverResponseOnSuccess() {
        
        let otpEventID = UUID().uuidString
        let phone = "+7..4589"
        let (sut, authenticateSpy, confirmProcessSpy, decryptSpy, _, _) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(otpEventID: .init(eventIDValue: otpEventID), phone: phone)), on: {
            authenticateSpy.complete(with: anySuccess())
            confirmProcessSpy.complete(with: anySuccess())
            decryptSpy.complete(with: .success(otpEventID))
            decryptSpy.complete(with: .success(phone), at: 1)
        })
    }
    
    func test_getPINConfirmationCode_shouldNotDeliverAuthenticateResultOnInstanceDeaalocation() {
        
        var sut: SUT?
        let authenticateSpy: AuthenticateSpy
        (sut, authenticateSpy, _, _, _, _) = makeSUT()
        var receivedResults = [SUT.GetPINConfirmationCodeResult]()
        
        sut?.getPINConfirmationCode { receivedResults.append($0) }
        sut = nil
        authenticateSpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_getPINConfirmationCode_shouldNotDeliverConfirmProcessResultOnInstanceDeaalocation() {
        
        var sut: SUT?
        let authenticateSpy: AuthenticateSpy
        let confirmProcessSpy: ConfirmProcessSpy
        (sut, authenticateSpy, confirmProcessSpy, _, _, _) = makeSUT()
        var receivedResults = [SUT.GetPINConfirmationCodeResult]()
        
        sut?.getPINConfirmationCode { receivedResults.append($0) }
        authenticateSpy.complete(with: anySuccess())
        sut = nil
        confirmProcessSpy.complete(with: anySuccess())
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_getPINConfirmationCode_shouldNotDeliverEventIDDecryptionResultOnInstanceDeaalocation() {
        
        var sut: SUT?
        let authenticateSpy: AuthenticateSpy
        let confirmProcessSpy: ConfirmProcessSpy
        let decryptSpy: DecryptSpy
        (sut, authenticateSpy, confirmProcessSpy, decryptSpy, _, _) = makeSUT()
        var receivedResults = [SUT.GetPINConfirmationCodeResult]()
        
        sut?.getPINConfirmationCode { receivedResults.append($0) }
        authenticateSpy.complete(with: anySuccess())
        confirmProcessSpy.complete(with: anySuccess())
        sut = nil
        decryptSpy.complete(with: .failure(anyError()))
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    func test_getPINConfirmationCode_shouldNotDeliverPhoneDecryptionResultOnInstanceDeaalocation() {
        
        var sut: SUT?
        let authenticateSpy: AuthenticateSpy
        let confirmProcessSpy: ConfirmProcessSpy
        let decryptSpy: DecryptSpy
        (sut, authenticateSpy, confirmProcessSpy, decryptSpy, _, _) = makeSUT()
        var receivedResults = [SUT.GetPINConfirmationCodeResult]()
        
        sut?.getPINConfirmationCode { receivedResults.append($0) }
        authenticateSpy.complete(with: anySuccess())
        confirmProcessSpy.complete(with: anySuccess())
        decryptSpy.complete(with: .success(UUID().uuidString))
        sut = nil
        decryptSpy.complete(with: .failure(anyError()), at: 1)
        
        XCTAssert(receivedResults.isEmpty)
    }
    
    // MARK: - changePIN
    
    func test_changePIN_shouldDeliverErrorONMakeJSONFailure() {
        
        let (sut, _, _, _, makeJSONSpy, _) = makeSUT()
        
        expectChangePIN(sut, toDeliver: .failure(.makeJSONFailure), on: {
            makeJSONSpy.complete(with: .failure(anyError()))
        })
    }
    
    func test_changePIN_shouldDeliverErrorONChangeProcessInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, _, _, _, makeJSONSpy, changePINProcessSpy) = makeSUT()
        
        expectChangePIN(sut, toDeliver: .failure(.invalid(statusCode: statusCode, data: invalidData)), on: {
            makeJSONSpy.complete(with: anySuccess())
            changePINProcessSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_changePIN_shouldDeliverErrorONChangeProcessNetworkFailure() {
        
        let (sut, _, _, _, makeJSONSpy, changePINProcessSpy) = makeSUT()
        
        expectChangePIN(sut, toDeliver: .failure(.network), on: {
            
            makeJSONSpy.complete(with: anySuccess())
            changePINProcessSpy.complete(with: .failure(.network))
        })
    }
    
    func test_changePIN_shouldDeliverErrorONChangeProcessRetryFailure() {
        
        let statusCode = 500
        let errorMessage = "Process Failure"
        let retryAttempts = 5
        let (sut, _, _, _, makeJSONSpy, changePINProcessSpy) = makeSUT()
        
        expectChangePIN(sut, toDeliver: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)), on: {
            makeJSONSpy.complete(with: anySuccess())
            changePINProcessSpy.complete(with: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)))
        })
    }
    
    func test_changePIN_shouldDeliverErrorONChangeProcessServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Process Failure"
        let (sut, _, _, _, makeJSONSpy, changePINProcessSpy) = makeSUT()
        
        expectChangePIN(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)), on: {
            makeJSONSpy.complete(with: anySuccess())
            changePINProcessSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_changePIN_shouldDeliverVoidOnSuccess() {
        
        let (sut, _, _, _, makeJSONSpy, changePINProcessSpy) = makeSUT()
        
        expectChangePIN(sut, toDeliver: .success(()), on: {
            
            makeJSONSpy.complete(with: anySuccess())
            changePINProcessSpy.complete(with: anySuccess())
        })
    }
    
    func test_changePIN_shouldNotDeliverMakeJSONResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let makeJSONSpy: MakeJSONSpy
        (sut, _, _, _, makeJSONSpy, _) = makeSUT()
        var receivedResults = [SUT.ChangePINResult]()
        
        sut?.changePIN(for: anyCardID(), to: anyPIN(), otp: anyOTP()) {
            
            receivedResults.append($0)
        }
        sut = nil
        makeJSONSpy.complete(with: anySuccess())
    }
    
    func test_changePIN_shouldNotDeliverChangePINProcessResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let makeJSONSpy: MakeJSONSpy
        let changePINProcessSpy: ChangePINProcessSpy
        (sut, _, _, _, makeJSONSpy, changePINProcessSpy) = makeSUT()
        var receivedResults = [SUT.ChangePINResult]()
        
        sut?.changePIN(for: anyCardID(), to: anyPIN(), otp: anyOTP()) {
            
            receivedResults.append($0)
        }
        makeJSONSpy.complete(with: anySuccess())
        sut = nil
        changePINProcessSpy.complete(with: .success(()))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ChangePINService
    private typealias AuthenticateSpy = Spy<Void, SUT.SessionID, SUT.AuthenticateError>
    private typealias ChangePINProcessSpy = Spy<(SUT.SessionID, Data), Void, SUT.ChangePINAPIError>
    private typealias ConfirmProcessSpy = Spy<SUT.SessionID, SUT.EncryptedConfirmResponse, SUT.ConfirmAPIError>
    private typealias DecryptSpy = Spy<String, String, Error>
    private typealias MakeJSONSpy = Spy<(SUT.CardID, SUT.PIN, SUT.OTP), (SUT.SessionID, Data), Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        authenticateSpy: AuthenticateSpy,
        confirmProcessSpy: ConfirmProcessSpy,
        decryptSpy: DecryptSpy,
        makeJSONSpy: MakeJSONSpy,
        changePINProcessSpy: ChangePINProcessSpy
    ) {
        let authenticateSpy = AuthenticateSpy()
        let confirmProcessSpy = ConfirmProcessSpy()
        let decryptSpy = DecryptSpy()
        let makeJSONSpy = MakeJSONSpy()
        let changePINProcessSpy = ChangePINProcessSpy()
        let sut = SUT(
            authenticate: authenticateSpy.process(completion:),
            publicRSAKeyDecrypt: decryptSpy.process(_:completion:),
            confirmProcess: confirmProcessSpy.process(_:completion:),
            makePINChangeJSON: makeJSONSpy.process(cardID:pin:otp:completion:),
            changePINProcess: changePINProcessSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(authenticateSpy, file: file, line: line)
        trackForMemoryLeaks(decryptSpy, file: file, line: line)
        trackForMemoryLeaks(confirmProcessSpy, file: file, line: line)
        trackForMemoryLeaks(makeJSONSpy, file: file, line: line)
        trackForMemoryLeaks(changePINProcessSpy, file: file, line: line)
        
        return (sut, authenticateSpy, confirmProcessSpy, decryptSpy, makeJSONSpy, changePINProcessSpy)
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
                (.failure(.decryptionFailure), .failure(.decryptionFailure)),
                (.failure(.network), .failure(.network)):
                break
                
            case let(
                .failure(.invalid(receivedStatusCode, receivedInvalidData)),
                .failure(.invalid(expectedStatusCode, expectedInvalidData))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedInvalidData, expectedInvalidData, file: file, line: line)
                
            case let(
                .failure(.server(receivedStatusCode, receivedErrorMessage)),
                .failure(.server(expectedStatusCode, expectedErrorMessage))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedErrorMessage, expectedErrorMessage, file: file, line: line)
                
            case let (
                .success(receivedSuccess),
                .success(expectedSuccess)
            ):
                XCTAssertNoDiff(receivedSuccess.equatable, expectedSuccess.equatable, file: file, line: line)
                
            default:
                XCTFail("\nExpected \(expectedResult), but got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectChangePIN(
        _ sut: SUT,
        toDeliver expectedResult: SUT.ChangePINResult,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.changePIN(for: anyCardID(), to: anyPIN(), otp: anyOTP()) { receivedResult in
            
            switch (receivedResult, expectedResult) {
                
            case (.failure(.activationFailure), .failure(.activationFailure)),
                (.failure(.authenticationFailure), .failure(.authenticationFailure)),
                (.failure(.makeJSONFailure), .failure(.makeJSONFailure)),
                (.failure(.network), .failure(.network)):
                break
                
            case let(
                .failure(.invalid(receivedStatusCode, receivedInvalidData)),
                .failure(.invalid(expectedStatusCode, expectedInvalidData))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedInvalidData, expectedInvalidData, file: file, line: line)
                
            case let(
                .failure(.retry(receivedStatusCode, receivedErrorMessage, receivedRetryAttempts)),
                .failure(.retry(expectedStatusCode, expectedErrorMessage, expectedRetryAttempts))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedErrorMessage, expectedErrorMessage, file: file, line: line)
                XCTAssertNoDiff(receivedRetryAttempts, expectedRetryAttempts, file: file, line: line)
                
            case let(
                .failure(.server(receivedStatusCode, receivedErrorMessage)),
                .failure(.server(expectedStatusCode, expectedErrorMessage))
            ):
                XCTAssertNoDiff(receivedStatusCode, expectedStatusCode, file: file, line: line)
                XCTAssertNoDiff(receivedErrorMessage, expectedErrorMessage, file: file, line: line)
                
            case (.success(()), .success(())):
                break
                
            default:
                XCTFail("\nExpected \(expectedResult), but got \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

private func anySuccess(
    sessionIDValue: String = UUID().uuidString
) -> ChangePINService.AuthenticateResult {
    
    .success(.init(sessionIDValue: sessionIDValue))
}

private func anySuccess(
    eventID: String = UUID().uuidString,
    phone: String = UUID().uuidString
) -> ChangePINService.ConfirmProcessResult {
    
    .success(.init(eventID: eventID, phone: phone))
}

private func anySuccess(
    eventID: String = UUID().uuidString,
    phone: String = UUID().uuidString
) -> ChangePINService.MakePINChangeJSONResult {
    
    .success((anySessionID(), anyData()))
}

func anySessionID(
    sessionIDValue: String = UUID().uuidString
) -> ChangePINService.SessionID {
    
    .init(sessionIDValue: sessionIDValue)
}

private func anySuccess(
) -> ChangePINService.ChangePINProcessResult {
    
    .success(())
}

private func anyCardID() -> ChangePINService.CardID {
    
    .init(cardIDValue: 12345678909)
}

private func anyPIN(
    pinValue: String = .init(UUID().uuidString.prefix(4))
) -> ChangePINService.PIN {
    
    .init(pinValue: pinValue)
}

private func anyOTP(
    otpValue: String = .init(UUID().uuidString.prefix(6))
) -> ChangePINService.OTP {
    
    .init(otpValue: otpValue)
}

private extension ChangePINService.ConfirmResponse {
    
    var equatable: EquatableConfirmResponse {
        
        .init(otpEventIDValue: otpEventID.eventIDValue, phone: phone)
    }
    
    struct EquatableConfirmResponse: Equatable {
        
        let otpEventIDValue: String
        let phone: String
    }
}

private extension Spy
where Payload == (ChangePINService.CardID, ChangePINService.PIN, ChangePINService.OTP) {
    
    func process(
        cardID: ChangePINService.CardID,
        pin: ChangePINService.PIN,
        otp: ChangePINService.OTP,
        completion: @escaping Completion
    ) {
        process((cardID, pin, otp), completion: completion)
    }
}
