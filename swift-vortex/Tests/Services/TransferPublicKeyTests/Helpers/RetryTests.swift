//
//  RetryTests.swift
//  
//
//  Created by Igor Malyarov on 07.08.2023.
//

import TransferPublicKey
import XCTest
import VortexTools

final class RetryTests: XCTestCase {
    
    func test_retry_shouldCallSuccessfulActionOnceOnZeroRetryAttempts() throws {
        
        let retryAttempts = 0
        let spy = Spy(stub: [success()])
        
        _ = try retry(attempts: retryAttempts, action: spy.action)
        
        XCTAssertEqual(spy.actionCallCount, 1)
    }
    
    func test_retry_shouldCallFailingActionOnceOnZeroRetryAttempts() throws {
        
        let retryAttempts = 0
        let spy = Spy(stub: [failure()])
        
        XCTAssertThrowsError(try retry(attempts: retryAttempts, action: spy.action))
        
        XCTAssertEqual(spy.actionCallCount, 1)
    }
    
    func test_retry_shouldCallAgainOnFailedAttemptOnOneRetryAttempt() throws {
        
        let retryAttempts = 1
        let spy = Spy(stub: [failure(), success()])
        
        _ = try retry(attempts: retryAttempts, action: spy.action)
        
        XCTAssertEqual(spy.actionCallCount, 2)
    }
    
    func test_retry_shouldFailAgainOnFailedAttemptOnOneRetryAttempt() throws {
        
        let retryAttempts = 1
        let spy = Spy(stub: [failure(), failure()])
        
        XCTAssertThrowsError(try retry(attempts: retryAttempts, action: spy.action))

        XCTAssertEqual(spy.actionCallCount, 2)
    }
    
    func test_retry_shouldRetryTwiceOnFailedAttemptOnTwoRetryAttempt() throws {
        
        let retryAttempts = 2
        let spy = Spy(stub: [failure(), failure(), success()])
        
        _ = try retry(attempts: retryAttempts, action: spy.action)
        
        XCTAssertEqual(spy.actionCallCount, 3)
    }
    
    // MARK: - Helpers
    
    private struct OK {}
    
    private final class Spy {
        
        typealias Result = Swift.Result<OK, Error>
        
        private var stub: [Result]
        private(set) var actionCallCount = 0
        
        init(stub: [Result]) {
         
            self.stub = stub
        }
        
        func action() throws -> OK {
            
            actionCallCount += 1
            return try stub.removeFirst().get()
        }
    }
    
    private func success() -> Spy.Result {
        
        .success(.init())
    }
    
    private func failure() -> Spy.Result {
        
        .failure(anyError())
    }
}
