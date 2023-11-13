//
//  FetchAdapterTests.swift
//  
//
//  Created by Igor Malyarov on 13.11.2023.
//

import Fetcher
import XCTest

final class FetchAdapterTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, fetchSpy) = makeSUT()
        
        XCTAssertEqual(fetchSpy.callCount, 0)
    }
    
    func test_fetch_shouldDeliverNewErrorOnFailure() {
        
        let (sut, fetchSpy) = makeSUT()
        
        expect(sut, toDeliver: .failure(.init(newErrorMessage: "Failure")),  on: {
            
            fetchSpy.complete(with: .failure(.init(message: "Failure")))
        })
    }
    
    func test_fetch_shouldDeliverNewSuccessOnSuccess() {
        
        let (sut, fetchSpy) = makeSUT()
        
        expect(sut, toDeliver: .success(.init(newItemValue: "a nice value")),  on: {
            
            fetchSpy.complete(with: .success(.init(value: "a nice value")))
        })
    }
    
    func test_fetch_shouldNotDeliverNewErrorOnInstanceDeallocation() {
        
        var sut: SUT?
        let fetchSpy: FetchSpy
        (sut, fetchSpy) = makeSUT()
        var newResult: SUT.NewFetchResult?
        
        sut?.fetch(anyRequest()) { newResult = $0 }
        sut = nil
        fetchSpy.complete(with: .failure(testError()))
        
        XCTAssertNil(newResult)
    }
    
    func test_fetch_shouldNotDeliverNewSuccessOnInstanceDeallocation() {
        
        var sut: SUT?
        let fetchSpy: FetchSpy
        (sut, fetchSpy) = makeSUT()
        var newResult: SUT.NewFetchResult?

        sut?.fetch(anyRequest()) { newResult = $0 }
        sut = nil
        fetchSpy.complete(with: .success(anyItem()))
        
        XCTAssertNil(newResult)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FetchAdapter<Request, Item, NewItem, TestError, NewError>
    private typealias FetchSpy = FetcherSpy<Request, Item, TestError>
    
    private func makeSUT(
        map: @escaping (Item) -> NewItem = { .init(newItemValue: $0.value) },
        mapError: @escaping (TestError) -> NewError = { .init(newErrorMessage: $0.message) },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        fetchSpy: FetchSpy
    ) {
        let fetchSpy = FetchSpy()
        let sut = SUT(
            fetch: fetchSpy.fetch(_:completion:),
            map: map,
            mapError: mapError
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, fetchSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with request: Request = anyRequest(),
        toDeliver expectedResult: SUT.NewFetchResult,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.fetch(request) { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (
                .failure(receivedError),
                .failure(expectedError)
            ):
                XCTAssertNoDiff(receivedError, expectedError, file: file, line: line)
                
            case let (.success(received), .success(expected)):
                XCTAssertNoDiff(received, expected, file: file, line: line)
                
            default:
                XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}

private func anyNewItem(
    newItemValue: String = UUID().uuidString
) -> NewItem {
    
    .init(newItemValue: newItemValue)
}

private struct NewItem: Equatable {
    
    let newItemValue: String
}

private func anyNewError(
    newErrorMessage: String = UUID().uuidString
) -> NewError {
    
    .init(newErrorMessage: newErrorMessage)
}

private struct NewError: Error & Equatable {
    
    let newErrorMessage: String
}
