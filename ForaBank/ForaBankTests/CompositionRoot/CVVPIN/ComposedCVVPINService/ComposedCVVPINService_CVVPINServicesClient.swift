//
//  ComposedCVVPINService_CVVPINServicesClient.swift
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

final class ComposedCVVPINService_CVVPINServicesClient: XCTestCase {
    
    // MARK: - ActivateCVVPINClient
    
    func test_activate_shouldDeliverSuccessOnSuccess() {
        
        let (sut, activateSpy, _, _) = makeSUT()
        
        expectActivate(sut, toDeliver: [.success("+7..3245")], on: {
            
            activateSpy.complete(with: anySuccess("+7..3245"))
        })
    }
    
    func test_activate_shouldDeliverFailureOnFailure() {
        
        let (sut, activateSpy, _, _) = makeSUT()
        
        expectActivate(sut, toDeliver: [.failure(.server(statusCode: 500, errorMessage: "Activation Failure"))], on: {
            
            activateSpy.complete(with: anyFailure(500, "Activation Failure"))
        })
    }
    
    func test_activate_shouldNotDeliverResultOnInstanceDeallocation() {
        
        let activateSpy: ActivateSpy
        var sut: SUT?
        (sut, activateSpy, _, _) = makeSUT()
        var results = [ActivateCVVPINClient.ActivateResult]()
        
        sut?.activate(completion: { results.append($0) })
        sut = nil
        activateSpy.complete(with: anySuccess())
        
        XCTAssert(results.isEmpty)
    }
    
    func test_confirmWith_shouldDeliverSuccessOnSuccess() {
        
        let (sut, _, confirmSpy, _) = makeSUT()
        
        expectConfirm(sut, toDeliver: [.success(())], on: {
            
            confirmSpy.complete(with: .success(()))
        })
    }
    
    func test_confirmWith_shouldDeliverFailureOnFailure() {
        
        let (sut, _, confirmSpy, _) = makeSUT()
        
        expectConfirm(sut, toDeliver: [.failure(.server(statusCode: 500, errorMessage: "Confirmation Failure"))], on: {
            
            confirmSpy.complete(with: anyFailure(500, "Confirmation Failure"))
        })
    }
    
    func test_confirmWith_shouldNotDeliverResultOnInstanceDeallocation() {
        
        let confirmSpy: ConfirmSpy
        var sut: SUT?
        (sut, _, confirmSpy, _) = makeSUT()
        var results = [ActivateCVVPINClient.ConfirmationResult]()
        
        sut?.confirmWith(otp: "123456", completion: { results.append($0) })
        sut = nil
        confirmSpy.complete(with: .success(()))
        
        XCTAssert(results.isEmpty)
    }
    
    // MARK: - ChangePINClient
    
    func test_checkFunctionality_shouldDeliverSuccessOnSuccess() {
        
        let (sut, _, _, checkSpy) = makeSUT()
        
        expectCheckFunctionality(sut, toDeliver: [.success(())], on: {
            
            checkSpy.complete(with: .success(()))
        })
    }
    
    func test_checkFunctionality_shouldDeliverFailureOnFailure() {
        
        let checkFailureMessage = "Check Failure"
        let (sut, _, _, checkSpy) = makeSUT()
        
        expectCheckFunctionality(sut, toDeliver: [.failure(.activationFailure)], on: {
            
            checkSpy.complete(with: .failure(anyError("Check Failure")))
        })
    }
    
    func test_checkFunctionality_shouldNotDeliverResultOnInstanceDeallocation() {
        
        let checkSpy: CheckSpy
        var sut: SUT?
        (sut, _, _, checkSpy) = makeSUT()
        var results = [ChangePINClient.CheckFunctionalityResult]()
        
        sut?.checkFunctionality(completion: { results.append($0) })
        sut = nil
        checkSpy.complete(with: .success(()))
        
        XCTAssert(results.isEmpty)
    }
    
    
    
    // MARK: - Helpers
    
    private typealias SUT = ComposedCVVPINService
    private typealias ActivateSpy = Spy<CVVPINFunctionalityActivationService.Phone, CVVPINFunctionalityActivationService.ActivateError>
    private typealias ConfirmSpy = Spy<Void, CVVPINFunctionalityActivationService.ConfirmError>
    private typealias CheckSpy = Spy<Void, Error>
    
    private func makeSUT(
        changePINResult: ChangePINResult = anySuccess(),
        getPINConfirmationCodeResult: GetPINConfirmationCodeResult = anySuccess(),
        showCVVResult: ShowCVVService.Result = anySuccess(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        activateSpy: ActivateSpy,
        confirmSpy: ConfirmSpy,
        checkSpy: CheckSpy
    ) {
        
        let activateSpy = ActivateSpy()
        let confirmSpy = ConfirmSpy()
        let checkSpy = CheckSpy()
        let sut = SUT(
            activate: activateSpy.perform(_:),
            changePIN: { _,_,_, completion  in completion(changePINResult) },
            checkActivation: checkSpy.perform(_:),
            confirmActivation: { _, completion  in confirmSpy.perform(completion) },
            getPINConfirmationCode: { $0(getPINConfirmationCodeResult) },
            showCVV: { _, completion in completion(showCVVResult) }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(activateSpy, file: file, line: line)
        trackForMemoryLeaks(confirmSpy, file: file, line: line)
        trackForMemoryLeaks(checkSpy, file: file, line: line)
        
        return (sut, activateSpy, confirmSpy, checkSpy)
    }
    
    final class Spy<Success, Failure: Error> {
        
        typealias Result = Swift.Result<Success, Failure>
        typealias Completion = (Result) -> Void
        
        private(set) var completions = [Completion]()
        
        func perform(
            _ completion: @escaping Completion
        ) {
            completions.append(completion)
        }
        
        func complete(
            with result: Result,
            at index: Int = 0
        ) {
            completions[index](result)
        }
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
    
    private func assert<T: Equatable, E: Error & Equatable>(
        _ receivedResults: [Result<T, E>],
        equals expectedResults: [Result<T, E>],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(receivedResults.count, expectedResults.count, "\n Expected \(expectedResults.count) values, but got \(receivedResults.count)", file: file, line: line)
        
        zip(receivedResults, expectedResults)
            .enumerated()
            .forEach { index, element in
                
                switch element {
                case let (
                    .failure(receivedError),
                    .failure(expectedError)
                ):
                    XCTAssertNoDiff(receivedError, expectedError, file: file, line: line)
                    
                case let (
                    .success(received),
                    .success(expected)
                ):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                default:
                    XCTFail("\nExpected \(element.1) at index \(index), but got \(element.0)", file: file, line: line)
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

private func anySuccess(
    _ cvvValue: String = .init(UUID().uuidString.prefix(3))
) -> ShowCVVService.Result {
    
    .success(.init(cvvValue: cvvValue))
}

private func anyFailure(
    _ statusCode: Int,
    _ errorMessage: String = UUID().uuidString
) -> ShowCVVService.Result {
    
    .failure(.server(statusCode: statusCode, errorMessage: errorMessage))
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
            .map { _ in EquatableVoid() }
            .mapError(ConfirmationCodeError.init)
    }
    
    struct EquatableVoid: Equatable {}
    
    typealias EquatableConfirmationResult = Result<EquatableVoid, ConfirmationCodeError>
    
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
            .map { _ in CheckEquatableVoid() }
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
