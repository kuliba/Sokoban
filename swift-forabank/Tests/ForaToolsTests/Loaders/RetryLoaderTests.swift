//
//  RetryLoaderTests.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import XCTest

final class RetryLoaderTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_load_shouldCallPerformerWithPayload() {
        
        let payload = anyPayload()
        let (sut, spy) = makeSUT()
        
        sut.load(payload) { _ in }
        
        XCTAssertNoDiff(spy.payloads, [payload])
    }

    func test_load_shouldDeliverSuccessOnPerformerSuccess() {
        
        let response = anyResponse()
        let (sut, spy) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            spy.complete(with: .success(response))
        }
    }
    
    func test_load_shouldDeliverFailureOnEmptyRetryIntervals() {
        
        let failure = anyLoadFailure()
        let (sut, spy) = makeSUT(retryIntervals: [])
        
        assert(sut, with: anyPayload(), toDeliver: .failure(failure)) {
            
            spy.complete(with: .failure(failure))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RetryLoader<Payload, Response, LoadFailure>
    private typealias LoadSpy = Spy<Payload, LoadResult>
    
    private typealias Payload = Int
    private typealias Response = String
    private typealias LoadResult = Result<Response, LoadFailure>
    
    private func makeSUT(
        retryIntervals: [DispatchTimeInterval] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LoadSpy
    ) {
        let spy = LoadSpy()
        let sut = SUT(performer: spy)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func anyPayload(
        _ value: Int = .random(in: 0...1_000)
    ) -> Payload {
        
        return value
    }
    
    private func anyResponse(
        _ value: String = UUID().uuidString
    ) -> Response {
        
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
        toDeliver expected: LoadResult,
        on action: () throws -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var result: LoadResult?
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
