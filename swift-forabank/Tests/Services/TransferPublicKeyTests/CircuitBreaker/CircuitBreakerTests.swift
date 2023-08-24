//
//  CircuitBreakerTests.swift
//  
//
//  Created by Igor Malyarov on 06.08.2023.
//

import TransferPublicKey
import XCTest

final class CircuitBreakerTests: XCTestCase {
    
    func test_retry_shouldCallAction() {
        
        let (sut, spy) = makeSUT()
        
        sut.retry()
        
        XCTAssertEqual(spy.actionCallCount, 1)
    }
    
    func test_retry_shouldCompleteWithSuccessOnSuccessfulAction() throws {
        
        let (sut, spy) = makeSUT()
        
        sut.retry()
        
        expect(spy, toCapture: [.ok], on: {
            spy.completeAction(with: .ok)
        })
    }
    
    func test_retry_shouldCompleteWithErrorOnFailedActionWithZeroRetryAttempts() throws {
        
        let noRetry = OKCircuitBreaker.ErrorWithRetry.noRetry
        let (sut, spy) = makeSUT()
        
        sut.retry()
        
        expect(spy, toCapture: [.failure(noRetry.error)], on: {
            spy.completeAction(with: .failure(noRetry))
        })
        XCTAssertFalse(noRetry.canRetry)
    }
    
    func test_retry_shouldCallActionAgainOnFailedActionWithRetry() throws {
        
        let withRetry = OKCircuitBreaker.ErrorWithRetry.withRetry
        let (sut, spy) = makeSUT()
        
        sut.retry()
        
        expect(spy, toCapture: [.ok], on: {
            spy.completeAction(with: .failure(withRetry), at: 0)
            spy.completeAction(with: .ok, at: 1)
        })
        XCTAssertEqual(spy.actionCallCount, 2)
        XCTAssertTrue(withRetry.canRetry)
    }
    
    func test_retry_shouldCallActionOnceAgainOnFailedActionWithRetryAndFinalSuccess() throws {
        
        let withRetry = OKCircuitBreaker.ErrorWithRetry.withRetry
        let (sut, spy) = makeSUT()
        
        sut.retry()
        
        expect(spy, toCapture: [.ok], on: {
            spy.completeAction(with: .failure(withRetry), at: 0)
            spy.completeAction(with: .failure(withRetry), at: 1)
            spy.completeAction(with: .failure(withRetry), at: 2)
            spy.completeAction(with: .ok, at: 3)
        })
        XCTAssertEqual(spy.actionCallCount, 4)
        XCTAssertTrue(withRetry.canRetry)
    }
    
    func test_retry_shouldCallActionAgainOnFailedActionWithRetryAndFinalFailure() throws {
        
        let withRetry = OKCircuitBreaker.ErrorWithRetry.withRetry
        let noRetry = OKCircuitBreaker.ErrorWithRetry.noRetry
        let (sut, spy) = makeSUT()
        
        sut.retry()
        
        expect(spy, toCapture: [.errorNoRetry], on: {
            spy.completeAction(with: .failure(withRetry))
            spy.completeAction(with: .failure(noRetry))
        })
        XCTAssertEqual(spy.actionCallCount, 2)
        XCTAssertTrue(withRetry.canRetry)
    }
    
    func test_retry_shouldNotDeliverResultOnSUTInstanceBeenDeallocated() throws {
        
        let spy = OKCircuitBreakerSpy()
        var sut: OKCircuitBreaker? = .init(
            action: spy.action,
            completion: spy.completion(result:)
        )
        
        sut?.retry()
        sut = nil
        spy.completeAction(with: .ok)
        
        XCTAssertEqual(spy.completionResults.count, 0)
    }
    
    // MARK: - Helpers
    
    fileprivate struct OK: Equatable {}
    
    fileprivate typealias OKCircuitBreaker = CircuitBreaker<OK>
    fileprivate typealias ActionCompletion = OKCircuitBreaker.ActionCompletion
    fileprivate typealias ActionResult = OKCircuitBreaker.ActionResult
    fileprivate typealias CompletionResult = OKCircuitBreaker.CompletionResult
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: OKCircuitBreaker,
        spy: OKCircuitBreakerSpy
    ) {
        
        let spy = OKCircuitBreakerSpy()
        let sut = OKCircuitBreaker(
            action: spy.action,
            completion: spy.completion(result:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func expect(
        _ spy: OKCircuitBreakerSpy,
        toCapture expectedResults: [CompletionResult],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        action()
        
        let receivedResults = spy.completionResults
        
        XCTAssertEqual(
            receivedResults.count,
            expectedResults.count,
            "Expected \(expectedResults.count) results, got \(receivedResults.count) instead",
            file: file, line: line
        )
        
        zip(receivedResults, expectedResults)
            .enumerated()
            .forEach { index, element in
                
                switch element {
                case let (
                    .failure(receivedError as NSError),
                    .failure(expectedError as NSError)
                ):
                    XCTAssertNoDiff(
                        receivedError,
                        expectedError,
                        "Expected \(expectedError), got \(receivedError) at index \(index) instead.",
                        file: file, line: line
                    )
                    
                case let (
                    .success(receivedSuccess),
                    .success(expectedSuccess)
                ):
                    XCTAssertNoDiff(
                        receivedSuccess,
                        expectedSuccess,
                        "Expected \(expectedSuccess), got \(receivedSuccess) at index \(index) instead.",
                        file: file, line: line
                    )
                    
                default:
                    XCTFail(
                        "Expected \(element.1), got \(element.0) at index \(index) instead.",
                        file: file, line: line
                    )
                }
            }
    }
    
    fileprivate final class OKCircuitBreakerSpy {
        
        private var actionCompletions = [ActionCompletion]()
        private(set) var completionResults = [CompletionResult]()
        
        var actionCallCount: Int { actionCompletions.count }
        
        func action(completion: @escaping ActionCompletion) {
            
            actionCompletions.append(completion)
        }
        
        func completion(result: CompletionResult) {
            
            completionResults.append(result)
        }
        
        func completeAction(
            with result: ActionResult,
            at index: Int = 0
        ) {
            actionCompletions[index](result)
        }
    }
}

fileprivate extension CircuitBreakerTests.OKCircuitBreaker.ActionResult {
    
    static let ok: Self = .success(.init())
    static let error: Self = .failure(.noRetry)
}

fileprivate extension CircuitBreakerTests.OKCircuitBreaker.ErrorWithRetry {
    
    static let noRetry: Self = .init(
        error: anyError("error no retry"),
        canRetry: false
    )
    static let withRetry: Self = .init(
        error: anyError("error with retry"),
        canRetry: true
    )
}

fileprivate extension CircuitBreakerTests.OKCircuitBreaker.CompletionResult {
    
    static let ok: Self = .success(.init())
    static let error: Self = .failure(anyError())
    static let errorNoRetry: Self = .failure(
        anyError("error no retry")
    )
}
