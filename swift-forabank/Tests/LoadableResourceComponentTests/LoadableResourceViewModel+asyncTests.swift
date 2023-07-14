//
//  LoadableResourceViewModel+asyncTests.swift
//  
//
//  Created by Igor Malyarov on 24.06.2023.
//

import LoadableResourceComponent
import XCTest

final class LoadableResourceViewModel_asyncTests: XCTestCase {
    
    func test_init_shouldSetStateToLoading() {
        
        let (_, spy) = makeSUT {
            try await Task.sleep(nanoseconds: .ms100)
            throw anyNSError()
        }
        
        assertEqual(spy.values, [.loading])
    }
    
    func test_shouldSetStateToErrorOnImmediateLoaderFailure() {
        
        let (_, spy) = makeSUT { throw anyNSError() }
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.01)
        
        assertEqual(spy.values, [
            .loading,
            .error(anyNSError()),
        ])
    }
    
    func test_shouldSetStateToErrorOnLoaderFailure() {
        
        let (_, spy) = makeSUT {
            
            try await Task.sleep(nanoseconds: .ms100)
            throw anyNSError()
        }
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.15)
        
        assertEqual(spy.values, [
            .loading,
            .error(anyNSError()),
        ])
    }
    
    func test_shouldSetStateToLoadedResultOnImmediateLoaderSuccess() {
        
        let (_, spy) = makeSUT { .init(id: 42) }
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.15)
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 42)),
        ])
    }
    
    func test_shouldSetStateToLoadedResultOnLoaderSuccess() {
        
        let (_, spy) = makeSUT {
            try await Task.sleep(nanoseconds: .ms100)
            return .init(id: 42)
        }
        
        assertEqual(spy.values, [
            .loading,
        ])
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.15)
        
        assertEqual(spy.values, [
            .loading,
            .loaded(.init(id: 42)),
        ])
    }
    
    // MARK: - Helpers
    
    fileprivate typealias ViewModel = LoadableResourceViewModel<TestResource>
    fileprivate typealias State = ViewModel.State
    
    private func makeSUT(
        _ operation: @escaping () async throws -> TestResource,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ViewModel,
        spy: ValueSpy<State>
    ) {
        let sut = ViewModel(operation: operation)
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func assertEqual(
        _ received: [State],
        _ expected: [State],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNoDiff(received.count, expected.count, "Received \(received.count) value(s), but expected \(expected.count).", file: file, line: line)
        
        zip(received, expected).enumerated().forEach { index, value in
            
            let (received, expected) = value
            
            switch (received, expected) {
            case (.loading, .loading):
                break
                
            case let (.error(received), .error(expected)):
                XCTAssertNoDiff(
                    received as NSError,
                    expected as NSError,
                    file: file, line: line
                )
                
            case let (.loaded(received), .loaded(expected)):
                XCTAssertNoDiff(
                    received,
                    expected,
                    file: file, line: line
                )
                
            default:
                XCTFail("Received \(received), but expected \(expected) at index \(index).", file: file, line: line)
            }
        }
    }
}

private struct TestResource: Equatable {
    
    let id: Int
}
