//
//  AsyncPublisherTests.swift
//  
//
//  Created by Igor Malyarov on 24.06.2023.
//

import Combine
import LoadableResourceComponent
import XCTest

@MainActor
final class AsyncPublisherTests: XCTestCase {
    
    func test_asyncPublisher_success() async throws {
        
        let action: () async throws -> TestItem = {
            
            try await Task.sleep(nanoseconds: .ms50)
            return .init(id: 42)
        }
        
        var receivedItem: TestItem?
        let cancellable = AnyPublisher(action)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    XCTFail("Expected value, got \(error).")
                case .finished:
                    break
                }
            } receiveValue: {
                receivedItem = $0
            }
        
        XCTAssertNil(receivedItem)
        
        try await Task.sleep(nanoseconds: .ms50)
        await Task.megaYield()
        
        XCTAssertNoDiff(receivedItem, .init(id: 42))
        XCTAssertNotNil(cancellable)
    }
    
    func test_asyncPublisher_success_usingSpy() async throws {
        
        let action: () async throws -> TestItem = {
            
            try await Task.sleep(nanoseconds: .ms50)
            return .init(id: 42)
        }
        
        let spy = ValueSpy(AnyPublisher(action))
        
        XCTAssertTrue(spy.events.isEmpty)
        
        try await Task.sleep(nanoseconds: .ms50)
        await Task.megaYield()
        
        assert(spy.events, [
            .value(.init(id: 42)),
            .finished,
        ])
    }
    
    func test_asyncPublisher_failure() async throws {
        
        let action: () async throws -> TestItem = {
            
            try await Task.sleep(nanoseconds: .ms50)
            throw anyNSError(domain: "Abc")
        }
        
        var receivedError: Error?
        let cancellable = AnyPublisher(action)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    receivedError = error
                case .finished:
                    break
                }
            } receiveValue: {
                XCTFail("Expected error, got \($0).")
            }
        
        XCTAssertNil(receivedError)
        
        try await Task.sleep(nanoseconds: .ms50)
        await Task.megaYield(count: 100)
        
        XCTAssertNoDiff(
            try XCTUnwrap(receivedError) as NSError,
            anyNSError(domain: "Abc")
        )
        XCTAssertNotNil(cancellable)
    }
    
    func test_asyncPublisher_failure_usingSpy() async throws {
        
        let action: () async throws -> TestItem = {
            
            try await Task.sleep(nanoseconds: .ms50)
            throw anyNSError(domain: "Abc")
        }
        
        let spy = ValueSpy(AnyPublisher(action))
        
        XCTAssertTrue(spy.events.isEmpty)
        
        try await Task.sleep(nanoseconds: .ms50)
        await Task.megaYield(count: 100)
        
        assert(spy.events, [.failure])
    }
}

private struct TestItem: Equatable {
    
    let id: Int
}
