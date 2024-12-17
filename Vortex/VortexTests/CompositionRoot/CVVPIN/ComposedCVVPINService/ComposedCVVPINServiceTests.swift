//
//  ComposedCVVPINServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

final class ComposedCVVPINServiceTests: XCTestCase {
    
    // MARK: - activate
    
    func test_activate_shouldDeliverServiceErrorOnActivateInvalidFailure() {
        
        let sut = makeSUT(
            activateResult: .failure(.invalid(statusCode: 500, data: anyData()))
        )
        
        expectActivate(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_activate_shouldDeliverServiceErrorOnActivateNetworkFailure() {
        
        let sut = makeSUT(
            activateResult: .failure(.network)
        )
        
        expectActivate(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_activate_shouldDeliverServerErrorOnActivateServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Activation Failure"
        let sut = makeSUT(
            activateResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        )
        
        expectActivate(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
    }
    
    func test_activate_shouldDeliverServiceErrorOnActivateServiceFailure() {
        
        let sut = makeSUT(
            activateResult: .failure(.serviceFailure)
        )
        
        expectActivate(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_activate_shouldDeliverPhoneOnActivateSuccess() {
        
        let phoneValue = "+7..7856"
        let sut = makeSUT(
            activateResult: anySuccess(phoneValue: phoneValue)
        )
        
        expectActivate(sut, toDeliver: .success(.init(phoneValue)))
    }
    
    // MARK: - confirmWith
    
    func test_confirmWith_shouldDeliverServiceErrorOnConfirmInvalidFailure() {
        
        let statusCode = 500
        let invalidData = anyData()
        let sut = makeSUT(
            confirmActivationResult: .failure(.invalid(statusCode: statusCode, data: invalidData))
        )
        
        expectConfirmWith(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_confirmWith_shouldDeliverServiceErrorOnConfirmNetworkFailure() {
        
        let sut = makeSUT(
            confirmActivationResult: .failure(.network)
        )
        
        expectConfirmWith(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_confirmWith_shouldDeliverRetryErrorOnConfirmRetryFailure() {
        
        let statusCode = 500
        let errorMessage = "Confirm Failure. Retry"
        let retryAttempts = 5
        let sut = makeSUT(
            confirmActivationResult: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts))
        )
        
        expectConfirmWith(sut, toDeliver: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)))
    }
    
    func test_confirmWith_shouldDeliverServerErrorOnConfirmServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Confirm Failure. Retry"
        let sut = makeSUT(
            confirmActivationResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        )
        
        expectConfirmWith(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
    }
    
    func test_confirmWith_shouldDeliverServiceErrorOnConfirmMakeJSONFailure() {
        
        let sut = makeSUT(
            confirmActivationResult: .failure(.serviceError(.makeJSONFailure))
        )
        
        expectConfirmWith(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_confirmWith_shouldDeliverServiceErrorOnConfirmMissingEventIDFailure() {
        
        let sut = makeSUT(
            confirmActivationResult: .failure(.serviceError(.missingEventID))
        )
        
        expectConfirmWith(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_confirmWith_shouldDeliverVoidOnConfirmSuccess() {
        
        let sut = makeSUT(
            confirmActivationResult: .success(())
        )
        
        expectConfirmWith(sut, toDeliver: .success(()))
    }
    
    // MARK: - checkFunctionality
    
    func test_checkFunctionality_shouldDeliverActivationErrorOnCheckActivationFailure() {
        
        let sut = makeSUT(
            checkActivationResult: .failure(anyNSError())
        )
        
        expectCheckFunctionality(sut, toDeliver: .failure(.activationFailure))
    }
    
    func test_expectCheckFunctionality_shouldDeliverVoidOnActivateSuccess() {
        
        let sut = makeSUT(
            checkActivationResult: .success(())
        )
        
        expectCheckFunctionality(sut, toDeliver: .success(()))
    }
    
    // MARK: - getPINConfirmationCode
    
    func test_getPINConfirmationCode_shouldDeliverActivationErrorOnActivationFailureFailure() {
        
        let sut = makeSUT(
            getPINConfirmationCodeResult: .failure(.activationFailure)
        )
        
        expectGetPINConfirmationCode(sut, toDeliver: .failure(.activationFailure))
    }
    
    func test_getPINConfirmationCode_shouldDeliverServiceErrorOnAuthenticationFailureFailure() {
        
        let sut = makeSUT(
            getPINConfirmationCodeResult: .failure(.authenticationFailure)
        )
        
        expectGetPINConfirmationCode(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_getPINConfirmationCode_shouldDeliverServiceErrorOnInvalidFailure() {
        
        let sut = makeSUT(
            getPINConfirmationCodeResult: .failure(.invalid(statusCode: 500, data: anyData()))
        )
        
        expectGetPINConfirmationCode(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_getPINConfirmationCode_shouldDeliverServiceErrorOnNetworkFailure() {
        
        let sut = makeSUT(
            getPINConfirmationCodeResult: .failure(.network)
        )
        
        expectGetPINConfirmationCode(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_getPINConfirmationCode_shouldDeliverServerErrorOnServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Activation Failure"
        let sut = makeSUT(
            getPINConfirmationCodeResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        )
        
        expectGetPINConfirmationCode(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
    }
    
    func test_getPINConfirmationCode_shouldDeliverServiceErrorOnCheckSessionFailureFailure() {
        
        let sut = makeSUT(
            getPINConfirmationCodeResult: .failure(.authenticationFailure)
        )
        
        expectGetPINConfirmationCode(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_getPINConfirmationCode_shouldDeliverServiceErrorOnDecryptionFailure() {
        
        let sut = makeSUT(
            getPINConfirmationCodeResult: .failure(.decryptionFailure)
        )
        
        expectGetPINConfirmationCode(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_getPINConfirmationCode_shouldDeliverVoidOnSuccess() {
        
        let phone = "+7..9876"
        let sut = makeSUT(
            getPINConfirmationCodeResult: .success(.init(otpEventID: anyOTPEventID(), phone: phone))
        )
        
        expectGetPINConfirmationCode(sut, toDeliver: .success(phone))
    }
    
    // MARK: - changePin
    
    func test_changePin_shouldDeliverServiceErrorOnActivationFailureFailure() {
        
        let sut = makeSUT(
            changePINResult: .failure(.activationFailure)
        )
        
        expectChangePin(sut, toDeliver: .failure(.activationFailure))
    }
    
    func test_changePin_shouldDeliverServiceErrorOnAuthenticationFailureFailure() {
        
        let sut = makeSUT(
            changePINResult: .failure(.authenticationFailure)
        )
        
        expectChangePin(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_changePin_shouldDeliverServiceErrorOnInvalidFailure() {
        
        let sut = makeSUT(
            changePINResult: .failure(.invalid(statusCode: 500, data: anyData()))
        )
        
        expectChangePin(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_changePin_shouldDeliverServiceErrorOnNetworkFailure() {
        
        let sut = makeSUT(
            changePINResult: .failure(.network)
        )
        
        expectChangePin(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_changePin_shouldDeliverRetryErrorOnRetryFailure() {
        
        let statusCode = 500
        let errorMessage = "Activation Failure"
        let retryAttempts = 4
        let sut = makeSUT(
            changePINResult: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts))
        )
        
        expectChangePin(sut, toDeliver: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)))
    }
    
    func test_changePin_shouldDeliverServerErrorOnServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Activation Failure"
        let sut = makeSUT(
            changePINResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        )
        
        expectChangePin(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
    }
    
    func test_changePin_shouldDeliverServiceErrorOnCheckSessionFailureFailure() {
        
        let sut = makeSUT(
            changePINResult: .failure(.makeJSONFailure)
        )
        
        expectChangePin(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_changePin_shouldDeliverServiceErrorOnDecryptionFailure() {
        
        let sut = makeSUT(
            changePINResult: .failure(.makeJSONFailure)
        )
        
        expectChangePin(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_changePin_shouldDeliverServiceErrorOnMakeJSONFailure() {
        
        let sut = makeSUT(
            changePINResult: .failure(.makeJSONFailure)
        )
        
        expectChangePin(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_changePin_shouldDeliverVoidOnActivateSuccess() {
        
        let sut = makeSUT(
            changePINResult: .success(())
        )
        
        expectChangePin(sut, toDeliver: .success(()))
    }
    
    // MARK: - showCVV
    
    func test_showCVV_shouldDeliverActivationErrorOnActivationFailureFailure() {
        
        let sut = makeSUT(
            showCVVResult: .failure(.activationFailure)
        )
        
        expectShowCVV(sut, toDeliver: .failure(.activationFailure))
    }
    
    func test_showCVV_shouldDeliverServiceErrorOnAuthenticationFailureFailure() {
        
        let sut = makeSUT(
            showCVVResult: .failure(.authenticationFailure)
        )
        
        expectShowCVV(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_showCVV_shouldDeliverServiceErrorOnInvalidFailure() {
        
        let sut = makeSUT(
            showCVVResult: .failure(.invalid(statusCode: 500, data: anyData()))
        )
        
        expectShowCVV(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_showCVV_shouldDeliverServiceErrorOnNetworkFailure() {
        
        let sut = makeSUT(
            showCVVResult: .failure(.network)
        )
        
        expectShowCVV(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_showCVV_shouldDeliverServerErrorOnServerFailure() {
        
        let statusCode = 500
        let errorMessage = "Activation Failure"
        let sut = makeSUT(
            showCVVResult: .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        )
        
        expectShowCVV(sut, toDeliver: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
    }
    
    func test_showCVV_shouldDeliverServiceErrorOnDecryptionFailure() {
        
        let sut = makeSUT(
            showCVVResult: .failure(.serviceError(.decryptionFailure))
        )
        
        expectShowCVV(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_showCVV_shouldDeliverServiceErrorOnMakeJSONFailure() {
        
        let sut = makeSUT(
            showCVVResult: .failure(.serviceError(.makeJSONFailure))
        )
        
        expectShowCVV(sut, toDeliver: .failure(.serviceFailure))
    }
    
    func test_showCVV_shouldDeliverVoidOnActivateSuccess() {
        
        let cvv = "951"
        let sut = makeSUT(
            showCVVResult: .success(.init(cvvValue: cvv))
        )
        
        expectShowCVV(sut, toDeliver: .success(.init(cvv)))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ComposedCVVPINService
    
    private func makeSUT(
        activateResult: CVVPINActivateResult = anySuccess(),
        changePINResult: ChangePINResult = anySuccess(),
        checkActivationResult: Result<Void, Error> = .success(()),
        confirmActivationResult: BindPublicKeyWithEventIDService.Result = .success(()),
        getPINConfirmationCodeResult: GetPINConfirmationCodeResult = anySuccess(),
        showCVVResult: ShowCVVService.Result = anySuccess(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            changePIN: { _,_,_, completion  in completion(changePINResult) },
            checkActivation: { $0(checkActivationResult) },
            confirmActivation: { _, completion  in completion(confirmActivationResult) },
            getPINConfirmationCode: { $0(getPINConfirmationCodeResult) },
            initiateActivation: { $0(activateResult) },
            showCVV: { _, completion in completion(showCVVResult) }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expectActivate(
        _ sut: SUT,
        toDeliver expectedResult: ActivateCVVPINClient.ActivateResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.activate(completion: { receivedResult in
            
            switch (expectedResult, receivedResult) {
                
            case let (
                .failure(expected as NSError),
                .failure(received as NSError)
            ):
                XCTAssertNoDiff(expected, received, file: file, line: line)
                
            case let (
                .success(expected),
                .success(received)
            ):
                XCTAssertNoDiff(expected, received, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult).", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectConfirmWith(
        _ sut: SUT,
        toDeliver expectedResult: ActivateCVVPINClient.ConfirmationResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.confirmWith(otp: UUID().uuidString, completion: { receivedResult in
            
            switch (expectedResult, receivedResult) {
                
            case let (
                .failure(expected as NSError),
                .failure(received as NSError)
            ):
                XCTAssertNoDiff(expected, received, file: file, line: line)
                
            case (.success(()), .success(())):
                break
                
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult).", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectCheckFunctionality(
        _ sut: SUT,
        toDeliver expectedResult: ChangePINClient.CheckFunctionalityResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.checkFunctionality(completion: { receivedResult in
            
            switch (expectedResult, receivedResult) {
                
            case let (
                .failure(expected as NSError),
                .failure(received as NSError)
            ):
                XCTAssertNoDiff(expected, received, file: file, line: line)
                
            case (.success(()), .success(())):
                break
                
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult).", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectGetPINConfirmationCode(
        _ sut: SUT,
        toDeliver expectedResult: ChangePINClient.GetPINConfirmationCodeResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.getPINConfirmationCode(completion: { receivedResult in
            
            switch (expectedResult, receivedResult) {
                
            case let (
                .failure(expected as NSError),
                .failure(received as NSError)
            ):
                XCTAssertNoDiff(expected, received, file: file, line: line)
                
            case let (.success(expected), .success(received)):
                XCTAssertNoDiff(expected, received, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult).", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectChangePin(
        _ sut: SUT,
        toDeliver expectedResult: ChangePINClient.ChangePINResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.changePin(
            cardId: 12345678901,
            newPin: UUID().uuidString,
            otp: UUID().uuidString,
            completion: { receivedResult in
                
                switch (expectedResult, receivedResult) {
                    
                case let (
                    .failure(expected as NSError),
                    .failure(received as NSError)
                ):
                    XCTAssertNoDiff(expected, received, file: file, line: line)
                    
                case (.success(()), .success(())):
                    break
                    
                default:
                    XCTFail("Expected \(expectedResult), but got \(receivedResult).", file: file, line: line)
                }
                
                exp.fulfill()
            })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expectShowCVV(
        _ sut: SUT,
        toDeliver expectedResult: ShowCVVClient.ShowCVVResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.showCVV(cardId: 12345678901, completion: { receivedResult in
            
            switch (expectedResult, receivedResult) {
                
            case let (
                .failure(expected as NSError),
                .failure(received as NSError)
            ):
                XCTAssertNoDiff(expected, received, file: file, line: line)
                
            case let (.success(expected), .success(received)):
                XCTAssertNoDiff(expected, received, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult).", file: file, line: line)
            }
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
}
