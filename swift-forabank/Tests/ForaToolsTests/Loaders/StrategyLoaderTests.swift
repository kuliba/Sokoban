//
//  StrategyLoaderTests.swift
//  
//
//  Created by Igor Malyarov on 24.06.2024.
//

import XCTest

final class StrategyLoaderTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, primary, secondary) = makeSUT()
        
        XCTAssertEqual(primary.callCount, 0)
        XCTAssertEqual(secondary.callCount, 0)
    }
    
    func test_load_shouldCallPrimaryWithPayload() {
        
        let payload = anyPayload()
        let (sut, primary, _) = makeSUT()
        
        sut.load(payload) { _ in }
        
        XCTAssertNoDiff(primary.payloads, [payload])
    }
    
    func test_load_shouldDeliverPrimaryResponseOnSuccess() {
        
        let response = anyResponse()
        let (sut, primary, _) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            primary.complete(with: .success(response))
        }
    }
    
    func test_load_shouldCallSecondaryOnPrimaryFailure() {
        
        let payload = anyPayload()
        let (sut, primary, secondary) = makeSUT()
        
        sut.load(payload) { _ in }
        primary.complete(with: .failure(anyLoadFailure()))
        
        XCTAssertNoDiff(secondary.payloads, [payload])
    }
    
    func test_load_shouldDeliverSecondaryResponseOnPrimaryFailure() {
        
        let response = anyResponse()
        let (sut, primary, secondary) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .success(response)) {
            
            primary.complete(with: .failure(anyLoadFailure()))
            secondary.complete(with: .success(response))
        }
    }
    
    func test_load_shouldDeliverSecondaryFailureOnBothFailure() {
        
        let secondaryFailure = anyLoadFailure()
        let (sut, primary, secondary) = makeSUT()
        
        assert(sut, with: anyPayload(), toDeliver: .failure(secondaryFailure)) {
            
            primary.complete(with: .failure(anyLoadFailure()))
            secondary.complete(with: .failure(secondaryFailure))
        }
    }
    
    func test_load_shouldNotDeliverSecondaryResponseOnInstanceDeallocation() {
        
        var sut: SUT?
        let (primary, secondary): (LoadSpy, LoadSpy)
        var results = [LoadResult]()
        (sut, primary, secondary) = makeSUT()
        
        sut?.load(anyPayload()) { results.append($0) }
        primary.complete(with: .failure(anyLoadFailure()))
        sut = nil
        secondary.complete(with: .failure(anyLoadFailure()))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = StrategyLoader<Payload, Response, LoadFailure>
    private typealias LoadSpy = Spy<Payload, LoadResult>
    
    private typealias Payload = Int
    private typealias Response = String
    private typealias LoadResult = Result<Response, LoadFailure>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        primary: LoadSpy,
        secondary: LoadSpy
    ) {
        let primary = LoadSpy()
        let secondary = LoadSpy()
        
        let sut = SUT(primary: primary, secondary: secondary)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(primary, file: file, line: line)
        trackForMemoryLeaks(secondary, file: file, line: line)
        
        return (sut, primary, secondary)
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
