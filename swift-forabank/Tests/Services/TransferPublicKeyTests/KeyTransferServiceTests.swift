//
//  KeyTransferServiceTests.swift
//  
//
//  Created by Igor Malyarov on 21.08.2023.
//

import TransferPublicKey
import XCTest

final class KeyTransferServiceTests: XCTestCase {
    
    func test_transfer_shouldDeliverErrorWithoutRetryOnSwaddleKeyError() {
        
        let swaddleKeyError = anyError("key swaddle")
        let errorWithoutRetry = ErrorWithRetry(
            error: swaddleKeyError,
            canRetry: false
        )
        let (sut, keySwaddlerSpy, _) = makeSUT()
        
        expect(
            sut,
            toDeliver: [.failure(errorWithoutRetry)],
            on: {
                keySwaddlerSpy.complete(with: .failure(swaddleKeyError))
            }
        )
    }
    
    func test_transfer_shouldDeliverErrorWithRetryOnBindKeyErrorWithRetryAttemptsGreaterThanZero() {
        
        let retryAttempts = 1
        let error = anyError()
        let errorWithRetry = ErrorWithRetry(
            error: error,
            canRetry: true
        )
        let bindKeyError = ErrorWithRetryAttempts(
            error: error,
            retryAttempts: retryAttempts
        )
        let (sut, keySwaddlerSpy, bindSpy) = makeSUT()
        
        expect(
            sut,
            toDeliver: [.failure(errorWithRetry)],
            on: {
                keySwaddlerSpy.complete(with: .success(anyData()))
                bindSpy.complete(with: .failure(bindKeyError))
            }
        )
        XCTAssertGreaterThan(retryAttempts, 0)
    }
    
    func test_transfer_shouldDeliverErrorWithoutRetryOnBindKeyErrorWithZeroRetryAttempts() {
        
        let retryAttempts = 0
        let error = anyError()
        let errorWithoutRetry = ErrorWithRetry(
            error: error,
            canRetry: false
        )
        let bindKeyError = ErrorWithRetryAttempts(
            error: error,
            retryAttempts: retryAttempts
        )
        let (sut, keySwaddlerSpy, bindSpy) = makeSUT()
        
        expect(
            sut,
            toDeliver: [.failure(errorWithoutRetry)],
            on: {
                keySwaddlerSpy.complete(with: .success(anyData()))
                bindSpy.complete(with: .failure(bindKeyError))
            }
        )
        XCTAssertEqual(retryAttempts, 0)
    }
    
    func test_transfer_shouldDeliverSuccessOnSuccess() {
        
        let (sut, keySwaddlerSpy, bindSpy) = makeSUT()
        
        expect(
            sut,
            toDeliver: [.success(())],
            on: {
                keySwaddlerSpy.complete(with: .success(anyData()))
                bindSpy.complete(with: .success(()))
            }
        )
    }
    
    func test_transfer_shouldNotDeliverSwaddleKeyOnSUTDeallocation() {
        
        let keySwaddler = KeySwaddlerSpy()
        let bindSpy = BingPublicKeyWithEventIDSpy()
        var sut: TransferService? = TransferService(
            swaddleKey: keySwaddler.swaddleKey,
            bindKey: bindSpy.bindKey
        )
        var results = [TransferResult]()
        
        sut?.transfer() {
            
            results.append($0)
        }
        sut = nil
        keySwaddler.complete(with: .failure(anyError()))
        
        XCTAssert(results.isEmpty)
    }
    
    func test_transfer_shouldNotDeliverResultSUTDeallocation() {
        
        let keySwaddler = KeySwaddlerSpy()
        let bindSpy = BingPublicKeyWithEventIDSpy()
        var sut: TransferService? = TransferService(
            swaddleKey: keySwaddler.swaddleKey,
            bindKey: bindSpy.bindKey
        )
        var results = [TransferResult]()
        
        sut?.transfer() {
            
            results.append($0)
        }
        keySwaddler.complete(with: .success(anyData()))
        sut = nil
        bindSpy.complete(with: .success(()))
        
        XCTAssert(results.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias TransferService = KeyTransferService<TestOTP, TestEventID>
    private typealias TransferResult = KeyTransferDomain.Result
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: TransferService,
        keySwaddlerSpy: KeySwaddlerSpy,
        bindSpy: BingPublicKeyWithEventIDSpy
    ) {
        let keySwaddler = KeySwaddlerSpy()
        let bindSpy = BingPublicKeyWithEventIDSpy()
        let sut = TransferService(
            swaddleKey: keySwaddler.swaddleKey,
            bindKey: bindSpy.bindKey
        )
        
        trackForMemoryLeaks(keySwaddler, file: file, line: line)
        trackForMemoryLeaks(bindSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, keySwaddler, bindSpy)
    }
    
    private func expect(
        _ sut: TransferService,
        toDeliver expectedResults: [TransferResult],
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResults = [TransferResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.transfer() {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(
            expectedResults.count,
            receivedResults.count,
            "\nExpected \(expectedResults.count) results, got \(receivedResults.count) instead.",
            file: file, line: line
        )
        
        zip(expectedResults, receivedResults)
            .enumerated()
            .forEach { index, element in
                
                switch element {
                case let (
                    .failure(expectedError as NSError),
                    .failure(receivedError as NSError)
                ):
                    XCTAssertNoDiff(
                        expectedError,
                        receivedError,
                        "\nExpected \(expectedError) at index \(index), got \(receivedError) instead.",
                        file: file, line: line
                    )
                    
                case (.success, .success):
                    break
                    
                default:
                    XCTFail(
                        "\nExpected \(element.0) at index \(index), got \(element.1) instead.",
                        file: file, line: line
                    )
                }
            }
    }
    
    
    private final class KeySwaddlerSpy {
        
        typealias TestSwaddleKeyDomain = SwaddleKeyDomain<TestOTP>
        typealias Result = TestSwaddleKeyDomain.Result
        typealias Completion = TestSwaddleKeyDomain.Completion
        typealias SharedSecret = TestSwaddleKeyDomain.SharedSecret
        
        private(set) var completions = [Completion]()
        
        func swaddleKey(
            otp: TestOTP,
            sharedSecret: SharedSecret,
            completion: @escaping Completion
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
    
    private final class BingPublicKeyWithEventIDSpy {
        
        typealias TestBindKeyDomain = BindKeyDomain<TestEventID>
        typealias Result = TestBindKeyDomain.Result
        typealias Completion = (Result) -> Void
        
        private(set) var completions = [Completion]()
        
        func bindKey(
            payload: TestBindKeyDomain.Payload,
            completion: @escaping Completion
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
}

// MARK: - Helpers

private struct TestEventID {
    
    let value: String
}

struct TestOTP {
    
    let value: String
}

private func anyOTP() -> TestOTP {
    
    .init(value: UUID().uuidString)
}

private func anyEventID() -> TestEventID {
    
    .init(value: UUID().uuidString)
}

// MARK: - DSL

private extension KeyTransferService
where EventID == TestEventID,
      OTP == TestOTP {
    
    func transfer(completion: @escaping TransferCompletion) {
        
        transfer(otp: anyOTP(), eventID: anyEventID(), sharedSecret: anySharedSecret(), completion: completion)
    }
}
