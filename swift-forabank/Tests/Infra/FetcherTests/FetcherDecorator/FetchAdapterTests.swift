//
//  FetchAdapterTests.swift
//  
//
//  Created by Igor Malyarov on 13.11.2023.
//

import Fetcher
import XCTest

final class FetchAdapter<Payload, Success, NewSuccess, Failure, NewFailure>
where Failure: Error,
      NewFailure: Error {
    
    typealias FetchResult = Result<Success, Failure>
    typealias FetchCompletion = (FetchResult) -> Void
    typealias Fetch = (Payload, @escaping FetchCompletion) -> Void
    
    typealias Map = (Success) -> NewSuccess
    typealias MapError = (Failure) -> NewFailure
    
    private let _fetch: Fetch
    private let map: Map
    private let mapError: MapError
    
    init(
        fetch: @escaping Fetch,
        map: @escaping Map,
        mapError: @escaping MapError
    ) {
        self._fetch = fetch
        self.map = map
        self.mapError = mapError
    }
}

extension FetchAdapter: Fetcher {
    
    typealias NewFetchResult = Result<NewSuccess, NewFailure>
    typealias NewFetchCompletion = (NewFetchResult) -> Void
    
    func fetch(
        _ payload: Payload,
        completion: @escaping NewFetchCompletion
    ) {
        _fetch(payload) { [weak self] result in
            
            guard let self else { return }
            
            completion(result.map(map).mapError(mapError))
        }
    }
}

#warning("Tests TBD")
extension FetchAdapter
where NewSuccess == Success {

    convenience init(
        fetch: @escaping Fetch,
        mapError: @escaping MapError
    ) {
        self.init(fetch: fetch, map: { $0 }, mapError: mapError)
    }
}

extension FetchAdapter
where NewFailure == Failure {

    convenience init(
        fetch: @escaping Fetch,
        map: @escaping Map
    ) {
        self.init(fetch: fetch, map: map, mapError: { $0 })
    }
}

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
