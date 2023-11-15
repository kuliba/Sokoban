//
//  ComposedCVVPINService_CVVPINServicesClient_Tests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

final class ComposedCVVPINService_CVVPINServicesClient_Tests: XCTestCase {
    
    // MARK: - ActivateCVVPINClient
    
    func test_activate_shouldDeliverServiceFailureOnInvalid() {
        
        let statusCode = 201
        let invalidData = anyData()
        let (sut, activateSpy, _,_,_,_,_) = makeSUT()
        
        expectActivate(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            activateSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_activate_shouldDeliverServiceFailureOnNetwork() {
        
        let (sut, activateSpy, _,_,_,_,_) = makeSUT()
        
        expectActivate(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            activateSpy.complete(with: .failure(.network))
        })
    }
    
    func test_activate_shouldDeliverServerFailureOnServer() {
        
        let statusCode = 500
        let errorMessage = "Activation Failure"
        let (sut, activateSpy, _,_,_,_,_) = makeSUT()
        
        expectActivate(sut, toDeliver: [.failure(.server(statusCode: statusCode, errorMessage: errorMessage))], on: {
            
            activateSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_activate_shouldDeliverServiceFailureOnServiceFailure() {
        
        let (sut, activateSpy, _,_,_,_,_) = makeSUT()
        
        expectActivate(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            activateSpy.complete(with: .failure(.serviceFailure))
        })
    }
    
    func test_activate_shouldDeliverSuccessOnSuccess() {
        
        let (sut, activateSpy, _,_,_,_,_) = makeSUT()
        
        expectActivate(sut, toDeliver: [.success("+7..3245")], on: {
            
            activateSpy.complete(with: anySuccess(phoneValue: "+7..3245"))
        })
    }
    
    func test_activate_shouldNotDeliverResultOnInstanceDeallocation() {
        
        let activateSpy: ActivateSpy
        var sut: SUT?
        (sut, activateSpy, _,_,_,_,_) = makeSUT()
        var results = [ActivateCVVPINClient.ActivateResult]()
        
        sut?.activate(completion: { results.append($0) })
        sut = nil
        activateSpy.complete(with: anySuccess())
        
        XCTAssert(results.isEmpty)
    }
    
    func test_confirmWith_shouldDeliverServiceFailureOnInvalid() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, _, confirmSpy, _,_,_,_) = makeSUT()
        
        expectConfirm(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            confirmSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_confirmWith_shouldDeliverServiceFailureOnNetwork() {
        
        let (sut, _, confirmSpy, _,_,_,_) = makeSUT()
        
        expectConfirm(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            confirmSpy.complete(with: .failure(.network))
        })
    }
    
    func test_confirmWith_shouldDeliverRetryFailureOnRetry() {
        
        let statusCode = 500
        let errorMessage = "Confirmation Failure"
        let retryAttempts = 5
        let (sut, _, confirmSpy, _,_,_,_) = makeSUT()
        
        expectConfirm(sut, toDeliver: [.failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts))], on: {
            
            confirmSpy.complete(with: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)))
        })
    }
    
    func test_confirmWith_shouldDeliverServerFailureOnServer() {
        
        let statusCode = 500
        let errorMessage = "Confirmation Failure"
        let (sut, _, confirmSpy, _,_,_,_) = makeSUT()
        
        expectConfirm(sut, toDeliver: [.failure(.server(statusCode: statusCode, errorMessage: errorMessage))], on: {
            
            confirmSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_confirmWith_shouldDeliverServiceFailureOnServiceMakeJSONFailure() {
        
        let (sut, _, confirmSpy, _,_,_,_) = makeSUT()
        
        expectConfirm(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            confirmSpy.complete(with: .failure(.serviceError(.makeJSONFailure)))
        })
    }
    
    func test_confirmWith_shouldDeliverServiceFailureOnServiceMissingEventIDFailure() {
        
        let (sut, _, confirmSpy, _,_,_,_) = makeSUT()
        
        expectConfirm(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            confirmSpy.complete(with: .failure(.serviceError(.missingEventID)))
        })
    }
    
    func test_confirmWith_shouldDeliverSuccessOnSuccess() {
        
        let (sut, _, confirmSpy, _,_,_,_) = makeSUT()
        
        expectConfirm(sut, toDeliver: [.success(())], on: {
            
            confirmSpy.complete(with: .success(()))
        })
    }
    
    func test_confirmWith_shouldNotDeliverResultOnInstanceDeallocation() {
        
        let confirmSpy: ConfirmSpy
        var sut: SUT?
        (sut, _, confirmSpy, _,_,_,_) = makeSUT()
        var results = [ActivateCVVPINClient.ConfirmationResult]()
        
        sut?.confirmWith(otp: "123456", completion: { results.append($0) })
        sut = nil
        confirmSpy.complete(with: .success(()))
        
        XCTAssert(results.isEmpty)
    }
    
    // MARK: - ChangePINClient
    
    func test_checkFunctionality_shouldDeliverFailureOnFailure() {
        
        let (sut, _,_, checkSpy, _,_,_) = makeSUT()
        
        expectCheckFunctionality(sut, toDeliver: [.failure(.activationFailure)], on: {
            
            checkSpy.complete(with: .failure(anyError("Check Failure")))
        })
    }
    
    func test_checkFunctionality_shouldDeliverSuccessOnSuccess() {
        
        let (sut, _,_, checkSpy, _,_,_) = makeSUT()
        
        expectCheckFunctionality(sut, toDeliver: [.success(())], on: {
            
            checkSpy.complete(with: .success(()))
        })
    }
    
    func test_checkFunctionality_shouldNotDeliverResultOnInstanceDeallocation() {
        
        let checkSpy: CheckSpy
        var sut: SUT?
        (sut, _,_, checkSpy, _,_,_) = makeSUT()
        var results = [ChangePINClient.CheckFunctionalityResult]()
        
        sut?.checkFunctionality(completion: { results.append($0) })
        sut = nil
        checkSpy.complete(with: .success(()))
        
        XCTAssert(results.isEmpty)
    }
    
    func test_getPINConfirmationCode_shouldDeliverActivationFailureOnActivationFailure() {
        
        let (sut, _,_,_, getPINConfirmationCodeSpy, _,_) = makeSUT()
        
        expectGetPINConfirmationCode(sut, toDeliver: [.failure(.activationFailure)], on: {
            
            getPINConfirmationCodeSpy.complete(with: .failure(.activationFailure))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverActivationFailureOnActivationAuthenticationFailure() {
        
        let (sut, _,_,_, getPINConfirmationCodeSpy, _,_) = makeSUT()
        
        expectGetPINConfirmationCode(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            getPINConfirmationCodeSpy.complete(with: .failure(.authenticationFailure))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverServiceFailureOnInvalid() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, _,_,_, getPINConfirmationCodeSpy, _,_) = makeSUT()
        
        expectGetPINConfirmationCode(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            getPINConfirmationCodeSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverServiceFailureOnNetwork() {
        
        let (sut, _,_,_, getPINConfirmationCodeSpy, _,_) = makeSUT()
        
        expectGetPINConfirmationCode(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            getPINConfirmationCodeSpy.complete(with: .failure(.network))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverServerFailureOnServer() {
        
        let statusCode = 500
        let errorMessage = "Error!"
        let (sut, _,_,_, getPINConfirmationCodeSpy, _,_) = makeSUT()
        
        expectGetPINConfirmationCode(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            getPINConfirmationCodeSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverServiceFailureOnDecryptionFailure() {
        
        let (sut, _,_,_, getPINConfirmationCodeSpy, _,_) = makeSUT()
        
        expectGetPINConfirmationCode(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            getPINConfirmationCodeSpy.complete(with: .failure(.decryptionFailure))
        })
    }
    
    func test_getPINConfirmationCode_shouldDeliverSuccessOnSuccess() {
        
        let eventID = UUID().uuidString
        let phone = "+7..8765"
        let (sut, _,_,_, getPINConfirmationCodeSpy, _,_) = makeSUT()
        
        expectGetPINConfirmationCode(sut, toDeliver: [.success(phone)], on: {
            
            getPINConfirmationCodeSpy.complete(with: anySuccess(eventID, phone))
        })
    }
    
    func test_getPINConfirmationCode_shouldNotDeliverResultOnInstanceDeallocation() {
        
        let getPINConfirmationCodeSpy: GetPINConfirmationCodeSpy
        var sut: SUT?
        (sut, _,_,_, getPINConfirmationCodeSpy, _,_) = makeSUT()
        var results = [ChangePINClient.GetPINConfirmationCodeResult]()
        
        sut?.getPINConfirmationCode(completion: { results.append($0) })
        sut = nil
        getPINConfirmationCodeSpy.complete(with: anySuccess())
        
        XCTAssert(results.isEmpty)
    }
    
    func test_changePIN_shouldDeliverActivationFailureOnActivationFailure() {
        
        let (sut, _,_,_,_, changePINSpy, _) = makeSUT()
        
        expectChangePIN(sut, toDeliver: [.failure(.activationFailure)], on: {
            
            changePINSpy.complete(with: .failure(.activationFailure))
        })
    }
    
    func test_changePIN_shouldDeliverServiceFailureOnAuthenticationFailure() {
        
        let (sut, _,_,_,_, changePINSpy, _) = makeSUT()
        
        expectChangePIN(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            changePINSpy.complete(with: .failure(.authenticationFailure))
        })
    }
    
    func test_changePIN_shouldDeliverServiceFailureOnInvalid() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, _,_,_,_, changePINSpy, _) = makeSUT()
        
        expectChangePIN(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            changePINSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_changePIN_shouldDeliverServiceFailureOnNetwork() {
        
        let (sut, _,_,_,_, changePINSpy, _) = makeSUT()
        
        expectChangePIN(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            changePINSpy.complete(with: .failure(.network))
        })
    }
    
    func test_changePIN_shouldDeliverRetryFailureOnRetry() {
        
        let statusCode = 500
        let errorMessage = "Error!"
        let retryAttempts = 5
        let (sut, _,_,_,_, changePINSpy, _) = makeSUT()
        
        expectChangePIN(sut, toDeliver: [
            .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts))
        ], on: {
            changePINSpy.complete(with: .failure(.retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)))
        })
    }
    
    func test_changePIN_shouldDeliverServerFailureOnServer() {
        
        let statusCode = 500
        let errorMessage = "Error!"
        let (sut, _,_,_,_, changePINSpy, _) = makeSUT()
        
        expectChangePIN(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            changePINSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_changePIN_shouldDeliverServiceFailureOnMakeJSONFailure() {
        
        let (sut, _,_,_,_, changePINSpy, _) = makeSUT()
        
        expectChangePIN(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            changePINSpy.complete(with: .failure(.makeJSONFailure))
        })
    }
    
    func test_changePIN_shouldDeliverSuccessOnSuccess() {
        
        let (sut, _,_,_,_, changePINSpy, _) = makeSUT()
        
        expectChangePIN(sut, toDeliver: [.success(())], on: {
            
            changePINSpy.complete(with: .success(()))
        })
    }
    
    func test_changePIN_shouldNotDeliverResultOnInstanceDeallocation() {
        
        let changePINSpy: ChangePINSpy
        var sut: SUT?
        (sut, _,_,_,_, changePINSpy, _) = makeSUT()
        var results = [ChangePINClient.ChangePINResult]()
        
        sut?.changePin(
            cardId: 98765432101,
            newPin: "5678",
            otp: "987654"
        ) { results.append($0) }
        sut = nil
        changePINSpy.complete(with: anySuccess())
        
        XCTAssert(results.isEmpty)
    }
    
    // MARK: - ShowCVVClient
    
    func test_showCVV_shouldDeliverActivationFailureOnActivationFailure() {
        
        let (sut, _,_,_,_,_, showCVVSpy) = makeSUT()
        
        expectShowCVV(sut, toDeliver: [.failure(.activationFailure)], on: {
            
            showCVVSpy.complete(with: .failure(.activationFailure))
        })
    }
    
    func test_showCVV_shouldDeliverServiceFailureOnAuthenticationFailure() {
        
        let (sut, _,_,_,_,_, showCVVSpy) = makeSUT()
        
        expectShowCVV(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            showCVVSpy.complete(with: .failure(.authenticationFailure))
        })
    }
    
    func test_showCVV_shouldDeliverServiceFailureOnConnectivity() {
        
        let (sut, _,_,_,_,_, showCVVSpy) = makeSUT()
        
        expectShowCVV(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            showCVVSpy.complete(with: .failure(.network))
        })
    }
    
    func test_showCVV_shouldDeliverServiceFailureOnInvalid() {
        
        let statusCode = 500
        let invalidData = anyData()
        let (sut, _,_,_,_,_, showCVVSpy) = makeSUT()
        
        expectShowCVV(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            showCVVSpy.complete(with: .failure(.invalid(statusCode: statusCode, data: invalidData)))
        })
    }
    
    func test_showCVV_shouldDeliverFailureOnFailure() {
        
        let statusCode = 500
        let errorMessage = "Error!"
        let (sut, _,_,_,_,_, showCVVSpy) = makeSUT()
        
        expectShowCVV(sut, toDeliver: [
            .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
        ], on: {
            showCVVSpy.complete(with: .failure(.server(statusCode: statusCode, errorMessage: errorMessage)))
        })
    }
    
    func test_showCVV_shouldDeliverServiceFailureOnDecryptionFailure() {
        
        let (sut, _,_,_,_,_, showCVVSpy) = makeSUT()
        
        expectShowCVV(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            showCVVSpy.complete(with: .failure(.serviceError(.decryptionFailure)))
        })
    }
    
    func test_showCVV_shouldDeliverServiceFailureOnMakeJSONFailure() {
        
        let (sut, _,_,_,_,_, showCVVSpy) = makeSUT()
        
        expectShowCVV(sut, toDeliver: [.failure(.serviceFailure)], on: {
            
            showCVVSpy.complete(with: .failure(.serviceError(.makeJSONFailure)))
        })
    }
    
    func test_showCVV_shouldDeliverSuccessOnSuccess() {
        
        let (sut, _,_,_,_,_, showCVVSpy) = makeSUT()
        
        expectShowCVV(sut, toDeliver: [.success(.init("369"))], on: {
            
            showCVVSpy.complete(with: .success(.init(cvvValue: "369")))
        })
    }
    
    func test_showCVV_shouldNotDeliverResultOnInstanceDeallocation() {
        
        let showCVVSpy: ShowCVVSpy
        var sut: SUT?
        (sut, _,_,_,_,_, showCVVSpy) = makeSUT()
        var results = [ShowCVVClient.ShowCVVResult]()
        
        sut?.showCVV(cardId: 98765432101) { results.append($0) }
        sut = nil
        showCVVSpy.complete(with: anySuccess())
        
        XCTAssert(results.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ComposedCVVPINService
    private typealias ActivateSpy = Spy<Void, CVVPINInitiateActivationService.ActivateSuccess, CVVPINInitiateActivationService.ActivateError>
    private typealias ConfirmSpy = Spy<Void, Void, BindPublicKeyWithEventIDService.Error>
    private typealias CheckSpy = Spy<Void, Void, Error>
    private typealias GetPINConfirmationCodeSpy = Spy<Void, ChangePINService.ConfirmResponse, ChangePINService.GetPINConfirmationCodeError>
    private typealias ChangePINSpy = Spy<Void, Void, ChangePINService.ChangePINError>
    private typealias ShowCVVSpy = Spy<Void, ShowCVVService.CVV, ShowCVVService.Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        activateSpy: ActivateSpy,
        confirmSpy: ConfirmSpy,
        checkSpy: CheckSpy,
        getPINConfirmationCodeSpy: GetPINConfirmationCodeSpy,
        changePINSpy: ChangePINSpy,
        showCVVSpy: ShowCVVSpy
    ) {
        let activateSpy = ActivateSpy()
        let confirmSpy = ConfirmSpy()
        let checkSpy = CheckSpy()
        let getPINConfirmationCodeSpy = GetPINConfirmationCodeSpy()
        let changePINSpy = ChangePINSpy()
        let showCVVSpy = ShowCVVSpy()
        let sut = SUT(
            changePIN: { _,_,_, completion  in changePINSpy.process(completion: completion) },
            checkActivation: checkSpy.process(completion:),
            confirmActivation: { _, completion  in confirmSpy.process(completion: completion) },
            getPINConfirmationCode: getPINConfirmationCodeSpy.process(completion:),
            initiateActivation: activateSpy.process(completion:),
            showCVV: { _, completion in showCVVSpy.process(completion: completion) }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(activateSpy, file: file, line: line)
        trackForMemoryLeaks(confirmSpy, file: file, line: line)
        trackForMemoryLeaks(checkSpy, file: file, line: line)
        trackForMemoryLeaks(getPINConfirmationCodeSpy, file: file, line: line)
        trackForMemoryLeaks(changePINSpy, file: file, line: line)
        trackForMemoryLeaks(showCVVSpy, file: file, line: line)
        
        return (sut, activateSpy, confirmSpy, checkSpy, getPINConfirmationCodeSpy, changePINSpy, showCVVSpy)
    }
    
    private func expectActivate(
        _ sut: SUT,
        toDeliver expectedResults: [ActivateCVVPINClient.ActivateResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [ActivateCVVPINClient.ActivateResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.activate {
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        assert(
            receivedResults.mapToEquatable(),
            equals: expectedResults.mapToEquatable(),
            file: file, line: line
        )
    }
    
    private func expectConfirm(
        _ sut: SUT,
        toDeliver expectedResults: [ActivateCVVPINClient.ConfirmationResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [ActivateCVVPINClient.ConfirmationResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.confirmWith(otp: "987654") {
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        assert(
            receivedResults.mapToEquatable(),
            equals: expectedResults.mapToEquatable(),
            file: file, line: line
        )
    }
    
    private func expectCheckFunctionality(
        _ sut: SUT,
        toDeliver expectedResults: [ChangePINClient.CheckFunctionalityResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [ChangePINClient.CheckFunctionalityResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.checkFunctionality {
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        assert(
            receivedResults.mapToEquatable(),
            equals: expectedResults.mapToEquatable(),
            file: file, line: line
        )
    }
    
    private func expectGetPINConfirmationCode(
        _ sut: SUT,
        toDeliver expectedResults: [ChangePINClient.GetPINConfirmationCodeResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [ChangePINClient.GetPINConfirmationCodeResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.getPINConfirmationCode {
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        assert(
            receivedResults.mapToEquatable(),
            equals: expectedResults.mapToEquatable(),
            file: file, line: line
        )
    }
    
    private func expectChangePIN(
        _ sut: SUT,
        toDeliver expectedResults: [ChangePINClient.ChangePINResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [ChangePINClient.ChangePINResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.changePin(
            cardId: 98765432101,
            newPin: anyPIN().pinValue,
            otp: .init(UUID().uuidString.prefix(6))
        ) {
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        assert(
            receivedResults.mapToEquatable(),
            equals: expectedResults.mapToEquatable(),
            file: file, line: line
        )
    }
    
    private func expectShowCVV(
        _ sut: SUT,
        toDeliver expectedResults: [ShowCVVClient.ShowCVVResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [ShowCVVClient.ShowCVVResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.showCVV(cardId: 98765432101) {
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        assert(
            receivedResults.mapToEquatable(),
            equals: expectedResults.mapToEquatable(),
            file: file, line: line
        )
    }
}

private extension ComposedCVVPINService {
    
    func changePIN(
        completion: @escaping ChangePINService.ChangePINCompletion
    ) {
        changePIN(anyCardID(), anyPIN(), anyOTP(), completion)
    }
    
    func confirmActivation(
        completion: @escaping BindPublicKeyWithEventIDService.Completion
    ) {
        confirmActivation(anyOTP(), completion)
    }
}

private func anyOTP(
    otpValue: String = UUID().uuidString
) -> BindPublicKeyWithEventIDService.OTP {
    
    .init(otpValue: otpValue)
}

private extension Array where Element == ActivateCVVPINClient.ActivateResult {
    
    func mapToEquatable() -> [ActivateCVVPINClient.ActivateResult.EquatableActivateResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension ActivateCVVPINClient.ActivateResult {
    
    func mapToEquatable() -> EquatableActivateResult {
        
        self
            .map(\.rawValue)
            .mapError(ActivateCVVPINError.init)
    }
    
    typealias EquatableActivateResult = Result<String, ActivateCVVPINError>
    
    enum ActivateCVVPINError: Error & Equatable {
        
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
        
        init(_ error: ForaBank.ActivateCVVPINError) {
            
            switch error {
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case .serviceFailure:
                self = .serviceFailure
            }
        }
    }
}

private extension Array where Element == ActivateCVVPINClient.ConfirmationResult {
    
    func mapToEquatable() -> [ActivateCVVPINClient.ConfirmationResult.EquatableConfirmationResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension ActivateCVVPINClient.ConfirmationResult {
    
    func mapToEquatable() -> EquatableConfirmationResult {
        
        self
            .map { (_: Void) in ConfirmationEquatableVoid() }
            .mapError(ConfirmationCodeError.init)
    }
    
    struct ConfirmationEquatableVoid: Equatable {}
    
    typealias EquatableConfirmationResult = Result<ConfirmationEquatableVoid, ConfirmationCodeError>
    
    enum ConfirmationCodeError: Error & Equatable {
        
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
        
        init(_ error: ForaBank.ConfirmationCodeError) {
            
            switch error {
            case let .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts):
                self = .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case .serviceFailure:
                self = .serviceFailure
            }
        }
    }
}

private extension Array where Element == ChangePINClient.CheckFunctionalityResult {
    
    func mapToEquatable() -> [ChangePINClient.CheckFunctionalityResult.EquatableCheckResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension ChangePINClient.CheckFunctionalityResult {
    
    func mapToEquatable() -> EquatableCheckResult {
        
        self
            .map { (_: Void) in CheckEquatableVoid() }
            .mapError(_CheckCVVPINFunctionalityError.init)
    }
    
    typealias EquatableCheckResult = Result<CheckEquatableVoid, _CheckCVVPINFunctionalityError>
    
    struct CheckEquatableVoid: Equatable {}
    
    enum _CheckCVVPINFunctionalityError: Error & Equatable {
        
        case activationFailure
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
        
        init(_ error: ForaBank.CheckCVVPINFunctionalityError) {
            
            switch error {
            case .activationFailure:
                self = .activationFailure
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case .serviceFailure:
                self = .serviceFailure
            }
        }
    }
}

private extension Array where Element == ChangePINClient.GetPINConfirmationCodeResult {
    
    func mapToEquatable() -> [ChangePINClient.GetPINConfirmationCodeResult.EquatableGetPINConfirmationCodeResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension ChangePINClient.GetPINConfirmationCodeResult {
    
    func mapToEquatable() -> EquatableGetPINConfirmationCodeResult {
        
        mapError(_GetPINConfirmationCodeError.init)
    }
    
    typealias EquatableGetPINConfirmationCodeResult = Result<String, _GetPINConfirmationCodeError>
    
    enum _GetPINConfirmationCodeError: Error & Equatable {
        
        case activationFailure
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
        
        init(_ error: ForaBank.GetPINConfirmationCodeError) {
            
            switch error {
            case .activationFailure:
                self = .activationFailure
             
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case .serviceFailure:
                self = .serviceFailure
            }
        }
    }
}

private extension Array where Element == ChangePINClient.ChangePINResult {
    
    func mapToEquatable() -> [ChangePINClient.ChangePINResult.EquatableChangePINResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension ChangePINClient.ChangePINResult {
    
    func mapToEquatable() -> EquatableChangePINResult {
        
        self
            .map { (_: Void) in ChangePINEquatableVoid() }
            .mapError(_ChangePINError.init)
    }
    
    struct ChangePINEquatableVoid: Equatable {}
    
    typealias EquatableChangePINResult = Result<ChangePINEquatableVoid, _ChangePINError>
    
    enum _ChangePINError: Error & Equatable {
        
        case activationFailure
        case retry(statusCode: Int, errorMessage: String, retryAttempts: Int)
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
        case weakPIN(statusCode: Int, errorMessage: String)
        
        init(_ error: ForaBank.ChangePINError) {
            
            switch error {
            case .activationFailure:
                self = .activationFailure
                
            case let .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts):
                self = .retry(statusCode: statusCode, errorMessage: errorMessage, retryAttempts: retryAttempts)
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case .serviceFailure:
                self = .serviceFailure
                
            case let .weakPIN(statusCode: statusCode, errorMessage: errorMessage):
                self = .weakPIN(statusCode: statusCode, errorMessage: errorMessage)
            }
        }
    }
}

private extension Array where Element == ShowCVVClient.ShowCVVResult {
    
    func mapToEquatable() -> [ShowCVVClient.ShowCVVResult.EquatableShowCVVResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension ShowCVVClient.ShowCVVResult {
    
    func mapToEquatable() -> EquatableShowCVVResult {
        
        self
            .map(\.rawValue)
            .mapError(_ShowCVVError.init)
    }
    
    typealias EquatableShowCVVResult = Result<String, _ShowCVVError>
    
    enum _ShowCVVError: Error & Equatable {
        
        case activationFailure
        case server(statusCode: Int, errorMessage: String)
        case serviceFailure
        
        init(_ error: ForaBank.ShowCVVError) {
            
            switch error {
            case .activationFailure:
                self = .activationFailure
                
            case let .server(statusCode: statusCode, errorMessage: errorMessage):
                self = .server(statusCode: statusCode, errorMessage: errorMessage)
                
            case .serviceFailure:
                self = .serviceFailure
            }
        }
    }
}
