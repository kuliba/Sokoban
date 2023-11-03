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
        
        let (sut, activateSpy) = makeSUT()
        
        expectActivate(sut, toDeliver: [.success("+7..3245")], on: {
            
            activateSpy.complete(with: anySuccess("+7..3245"))
        })
    }

    func test_activate_shouldDeliverFailureOnFailure() {
        
        let (sut, activateSpy) = makeSUT()
        
        expectActivate(sut, toDeliver: [.failure(.server(statusCode: 500, errorMessage: "Activation Failure"))], on: {
            
            activateSpy.complete(with: anyFailure(500, "Activation Failure"))
        })
    }

    func test_activate_shouldNotDeliverResultOnInstanceDeallocation() {
        
        let activateSpy: ActivateSpy
        var sut: SUT?
        (sut, activateSpy) = makeSUT()
        var results = [ActivateCVVPINClient.ActivateResult]()
        
        sut?.activate(completion: { results.append($0) })
        sut = nil
        activateSpy.complete(with: anySuccess())
        
        XCTAssert(results.isEmpty)
    }

    // MARK: - Helpers
    
    private typealias SUT = ComposedCVVPINService
    private typealias ActivateSpy = Spy<CVVPINFunctionalityActivationService.Phone, CVVPINFunctionalityActivationService.ActivateError>
    
    private func makeSUT(
        changePINResult: ChangePINResult = anySuccess(),
        checkActivationResult: Result<Void, Error> = .success(()),
        confirmActivationResult: ConfirmResult = .success(()),
        getPINConfirmationCodeResult: GetPINConfirmationCodeResult = anySuccess(),
        showCVVResult: ShowCVVService.Result = anySuccess(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        activateSpy: ActivateSpy
    ) {
        
        let activateSpy = ActivateSpy()
        let sut = SUT(
            activate: activateSpy.perform(_:),
            changePIN: { _,_,_, completion  in completion(changePINResult) },
            checkActivation: { $0(checkActivationResult) },
            confirmActivation: { _, completion  in completion(confirmActivationResult) },
            getPINConfirmationCode: { $0(getPINConfirmationCodeResult) },
            showCVV: { _, completion in completion(showCVVResult) }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(activateSpy, file: file, line: line)
        
        return (sut, activateSpy)
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
    
    func mapToEquatable() -> [ActivateCVVPINClient.ActivateResult.EquatableResult] {
        
        map { $0.mapToEquatable() }
    }
}

private extension ActivateCVVPINClient.ActivateResult {
    
    func mapToEquatable() -> EquatableResult {
        
        self
            .map(\.rawValue)
            .mapError(ActivateCVVPINError.init)
    }
    
    typealias EquatableResult = Result<String, ActivateCVVPINError>
    
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
