//
//  ComposedCVVPINServiceLogTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 03.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

final class ComposedCVVPINServiceLogTests: XCTestCase {
    
    func test_init_shouldNotMessageLogger() {
        
        let (_, spy) = makeSUT()
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_shouldLogErrorOnActivateFailure() {
        
        let statusCode = 500
        let errorMessage = "Activation Failure"
        let (sut, spy) = makeSUT(
            activateResult: anyFailure(statusCode, errorMessage)
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.activate { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.error, .crypto, "Initiate Activation failure: server(statusCode: \(statusCode), errorMessage: \"\(errorMessage)\").")
        ])
    }
    
    func test_shouldLogInfoOnActivateSuccess() {
        
        let phoneValue = "+01234567"
        let (sut, spy) = makeSUT(
            activateResult: anySuccess(phoneValue: phoneValue)
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.activate { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.info, .crypto, "Initiate Activation success: \(phoneValue).")
        ])
    }
    
    func test_shouldLogErrorOnChangePINFailure() {
        
        let statusCode = 500
        let errorMessage = "Change PIN Failure"
        let (sut, spy) = makeSUT(
            changePINResult: anyFailure(statusCode, errorMessage)
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.changePIN { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.error, .crypto, "Change PIN failure: server(statusCode: \(statusCode), errorMessage: \"\(errorMessage)\").")
        ])
    }
    
    func test_shouldLogInfoOnChangePINSuccess() {
        
        let (sut, spy) = makeSUT(
            changePINResult: anySuccess()
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.changePIN { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.info, .crypto, "Change PIN success.")
        ])
    }
    
    func test_shouldLogErrorOnCheckActivationFailure() {
        
        let errorMessage = "Failure in Activation Checking"
        let (sut, spy) = makeSUT(
            checkActivationResult: .failure(anyError(errorMessage))
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.checkActivation { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.error, .crypto, "Check Activation failure: Error Domain=\(errorMessage) Code=0 \"(null)\".")
        ])
    }
    
    func test_shouldLogInfoOnCheckActivationSuccess() {
        
        let (sut, spy) = makeSUT(
            checkActivationResult: .success(())
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.checkActivation { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.info, .crypto, "Check Activation success.")
        ])
    }
    
    func test_shouldLogErrorOnConfirmActivationFailure() {
        
        let statusCode = 500
        let errorMessage = "Change PIN Failure"
        let (sut, spy) = makeSUT(
            confirmActivationResult: anyFailure(statusCode, errorMessage)
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.confirmActivation { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.error, .crypto, "Confirm Activation failure: server(statusCode: \(statusCode), errorMessage: \"\(errorMessage)\").")
        ])
    }
    
    func test_shouldLogInfoOnConfirmActivationSuccess() {
        
        let (sut, spy) = makeSUT(
            confirmActivationResult: .success(())
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.confirmActivation { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.info, .crypto, "Confirm Activation success.")
        ])
    }
    
    func test_shouldLogErrorOnGetPINConfirmationCodeFailure() {
        
        let statusCode = 500
        let errorMessage = "PIN Confirmation Code Failure"
        let (sut, spy) = makeSUT(
            getPINConfirmationCodeResult: anyFailure(statusCode, errorMessage)
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.getPINConfirmationCode { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.error, .crypto, "Get PIN Confirmation Code failure: server(statusCode: \(statusCode), errorMessage: \"\(errorMessage)\").")
        ])
    }
    
    func test_shouldLogInfoOnGetPINConfirmationCodeSuccess() {
        
        let eventIDValue = "efg678"
        let phone = "+7..5367"
        let (sut, spy) = makeSUT(
            getPINConfirmationCodeResult: anySuccess(eventIDValue, phone)
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.getPINConfirmationCode { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.info, .crypto, "Get PIN Confirmation Code success: \(eventIDValue), \(phone).")
        ])
    }
    
    func test_shouldLogErrorOnShowCVVFailure() {
        
        let statusCode = 500
        let errorMessage = "Show CVV Failure"
        let (sut, spy) = makeSUT(
            showCVVResult: anyFailure(statusCode, errorMessage)
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.showCVV(anyCardID()) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.error, .crypto, "Show CVV failure: server(statusCode: \(statusCode), errorMessage: \"\(errorMessage)\").")
        ])
    }
    
    func test_shouldLogInfoOnShowCVVSuccess() {
        
        let cvvValue = "367"
        let (sut, spy) = makeSUT(
            showCVVResult: anySuccess(cvvValue)
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.showCVV(anyCardID()) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.info, .crypto, "Show CVV success.")
        ])
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
    ) -> (
        sut: SUT,
        spy: LogSpy
    ) {
        
        let spy = LogSpy()
        let sut = SUT(
            changePIN: { _,_,_, completion  in completion(changePINResult) },
            checkActivation: { $0(checkActivationResult) },
            confirmActivation: { _, completion  in completion(confirmActivationResult) },
            getPINConfirmationCode: { $0(getPINConfirmationCodeResult) },
            initiateActivation: { $0(activateResult) },
            showCVV: { _, completion in completion(showCVVResult) },
            log: { level, category, text,_,_ in
                
                spy.log(level, category, text)
            }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
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
