//
//  ComposedCVVPINServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

fileprivate typealias ActivateResult = CVVPINFunctionalityActivationService.ActivateResult
fileprivate typealias ChangePINResult = ChangePINService.ChangePINResult
fileprivate typealias ConfirmResult = CVVPINFunctionalityActivationService.ConfirmResult
fileprivate typealias GetPINConfirmationCodeResult = ChangePINService.GetPINConfirmationCodeResult

final class ComposedCVVPINServiceTests: XCTestCase {
    
    func test_init_shouldNotMessageLogger() {
        
        let (_, spy) = makeSUT()
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_shouldLogInfoOnActivateSuccess() {
        
        let phone = "+01234567"
        let (sut, spy) = makeSUT(
            activateResult: anySuccess(phone)
        )
        let exp = expectation(description: "wait for expectation")
        
        sut.activate { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.info, .crypto, "Activation success: Phone(phoneValue: \"\(phone)\").")
        ])
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
            .init(.error, .crypto, "Activation Failure: server(statusCode: \(statusCode), errorMessage: \"\(errorMessage)\").")
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
            .init(.error, .crypto, "Change PIN Failure: server(statusCode: \(statusCode), errorMessage: \"\(errorMessage)\").")
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
            .init(.error, .crypto, "Confirm Activation Failure: server(statusCode: \(statusCode), errorMessage: \"\(errorMessage)\").")
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
            .init(.error, .crypto, "Get PIN Confirmation Code Failure: server(statusCode: \(statusCode), errorMessage: \"\(errorMessage)\").")
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ComposedCVVPINService
    
    private func makeSUT(
        activateResult: ActivateResult = anySuccess(),
        changePINResult: ChangePINResult = anySuccess(),
        checkActivationResult: Result<Void, Error> = .success(()),
        confirmActivationResult: ConfirmResult = .success(()),
        getPINConfirmationCodeResult: GetPINConfirmationCodeResult = anySuccess(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LogSpy
    ) {
        
        let spy = LogSpy()
        let sut = SUT(
            activate: { $0(activateResult) },
            changePIN: { _,_,_, completion  in completion(changePINResult) },
            checkActivation: { $0(checkActivationResult) },
            confirmActivation: { _, completion  in completion(confirmActivationResult) },
            getPINConfirmationCode: { $0(getPINConfirmationCodeResult) },
            showCVV: { _,_  in },
            log: { level, category, text,_,_ in
                
                spy.log(level, category, text)
            }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private final class LogSpy {
        
        private(set) var messages = [Message]()
        
        func log(
            _ level: LoggerAgentLevel,
            _ category: LoggerAgentCategory,
            _ text: String
        ) {
            messages.append(.init(level, category, text))
        }
        
        struct Message: Equatable {
            
            let evel: LoggerAgentLevel
            let category: LoggerAgentCategory
            let text: String
            
            init(
                _ level: LoggerAgentLevel,
                _ category: LoggerAgentCategory,
                _ text: String
            ) {
                self.evel = level
                self.category = category
                self.text = text
            }
        }
    }
}

private func anySuccess(
    _ phoneValue: String = UUID().uuidString
) -> ActivateResult {
    
    .success(.init(phoneValue: phoneValue))
}

private func anyFailure(
    _ statusCode: Int,
    _ errorMessage: String = UUID().uuidString
) -> ActivateResult {
    
    .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
}

private func anySuccess() -> ChangePINResult {
    
    .success(())
}

private func anyFailure(
    _ statusCode: Int,
    _ errorMessage: String = UUID().uuidString
) -> ChangePINResult {
    
    .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
}

private extension ComposedCVVPINService {
    
    func changePIN(
        completion: @escaping ChangePINService.ChangePINCompletion
    ) {
        changePIN(anyCardID(), anyPIN(), anyOTP(), completion)
    }
    
    func confirmActivation(
        completion: @escaping CVVPINFunctionalityActivationService.ConfirmCompletion
    ) {
        confirmActivation(anyOTP(), completion)
    }
}

private func anyFailure(
    _ statusCode: Int,
    _ errorMessage: String = UUID().uuidString
) -> ConfirmResult {
    
    .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
}

private func anySuccess(
    _ eventIDValue: String = UUID().uuidString,
    _ phoneValue: String = UUID().uuidString
) -> GetPINConfirmationCodeResult {
    
    .success(.init(
        otpEventID: .init(eventIDValue: eventIDValue),
        phone: phoneValue
    ))
}

private func anyFailure(
    _ statusCode: Int,
    _ errorMessage: String = UUID().uuidString
) -> GetPINConfirmationCodeResult {
    
    .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
}

