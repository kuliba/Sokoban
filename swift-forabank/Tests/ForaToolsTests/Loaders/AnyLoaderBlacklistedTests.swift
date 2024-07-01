//
//  AnyLoaderBlacklistedTests.swift
//  
//
//  Created by Igor Malyarov on 25.06.2024.
//

import ForaTools
import XCTest

final class AnyLoaderBlacklistedTests: XCTestCase {
    
    func test_blacklisted_shouldNotCallDecorateeWhenRequestIsBlacklisted() {
        
        let (sut, decoratee) = makeSUT(isBlacklisted: { _,_ in true })
        
        assert(sut, with: anyPayload(), toDeliver: .failure(.blacklistedError))
        XCTAssertEqual(decoratee.callCount, 0)
    }
    
    func test_blacklisted_shouldCallDecorateeWhenRequestIsNotBlacklisted() {
        
        let response = anySuccess()
        let (sut, decoratee) = makeSUT(isBlacklisted: { _,_ in false })

        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            decoratee.complete(with: .success(response))
        }
        XCTAssertEqual(decoratee.callCount, 1)
    }
    
    func test_blacklisted_shouldIncrementAttemptsOnEachCall() {
        
        let payload = anyPayload()
        let failure = anyLoadFailure()
        var attemptCounts = [Int]()
        let (sut, decoratee) = makeSUT(isBlacklisted: { _, attempts in
            
            attemptCounts.append(attempts)
            return attempts > 1
        })
        
        assert(sut, with: payload, toDeliver: .failure(.loadFailure(failure))) {
            
            decoratee.complete(with: .failure(failure))
        }
        
        assert(sut, with: payload, toDeliver: .failure(.blacklistedError))
        
        XCTAssertEqual(attemptCounts, [1, 2])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnyLoader<Payload, BlacklistedResult>
    private typealias BlacklistedResult = Result<Success, BlacklistedError>
    private typealias BlacklistedError = BlacklistDecorator<Payload, Success, Failure>.Error
    
    private typealias LoadSpy = Spy<Payload, Result<Success, Failure>>
    
    private typealias Payload = Int
    private typealias Success = String
    private typealias Failure = LoadFailure
    
    private func makeSUT(
        isBlacklisted: @escaping (Payload, Int) -> Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        decoratee: LoadSpy
    ) {
        let decoratee = LoadSpy()
        let loader = AnyLoader(decoratee.load)
        let sut = loader.blacklisted(isBlacklisted: isBlacklisted)
        
        trackForMemoryLeaks(decoratee, file: file, line: line)
        
        return (sut, decoratee)
    }
    
    private func anyPayload(
        _ value: Int = .random(in: 0...1_000)
    ) -> Payload {
        
        return value
    }
    
    private func anySuccess(
        _ value: String = UUID().uuidString
    ) -> Success {
        
        return value
    }
    
    private func anyLoadFailure(
        _ value: String = UUID().uuidString
    ) -> LoadFailure {
        
        return .init(value: value)
    }

    private func assert(
        _ sut: SUT,
        with payload: Payload,
        toDeliver expected: BlacklistedResult,
        on action: () throws -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var result: BlacklistedResult?
        let exp = expectation(description: "wait for completion")
        
        sut.load(payload) {
            
            result = $0
            exp.fulfill()
        }
        
        try? action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertNoDiff(result, expected, file: file, line: line)
    }
    
    private struct LoadFailure: Error, Equatable {
        
        let value: String
    }
}
