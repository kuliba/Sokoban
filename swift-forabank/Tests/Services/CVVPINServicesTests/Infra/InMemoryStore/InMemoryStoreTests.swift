//
//  InMemoryStoreTests.swift
//  
//
//  Created by Igor Malyarov on 06.10.2023.
//

import CVVPINServices
import GenericLoader
import XCTest

final class InMemoryStoreTests: XCTestCase {
    
    func test_retrieve_ShouldDeliverEmptyCacheErrorOnEmptyCache() {
        
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .failure(SUT.StoreError.emptyCache))
    }
    
    func test_retrieve_shouldDeliverCacheOnNonEmptyCache() {
        
        let initialValue = Cached(
            makeModel(),
            validUntil: .init()
        )
        let sut = makeSUT(initialValue: initialValue)
        
        expect(sut, toRetrieve: .success(initialValue))
    }
    
    func test_retrieve_shouldHaveNoSideEffectsOnEmptyCache() {
        
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .failure(SUT.StoreError.emptyCache))
    }
    
    func test_retrieve_shouldDeliverFoundValuesOnNonEmptyCache() {
        
        let model = makeModel()
        let validUntil = Date()
        let sut = makeSUT()
        
        insert((model, validUntil), to: sut)
        
        expect(sut, toRetrieve: .success((model, validUntil: validUntil)))
    }
    
    func test_retrieve_shouldHaveNoSideEffectsOnNonEmptyCache() {
        
        let model = makeModel()
        let validUntil = Date()
        let sut = makeSUT()
        
        insert((model, validUntil), to: sut)
        
        expect(sut, toRetrieveTwice: .success((model, validUntil: validUntil)))
    }
    
    // useful for non-in-memory stores
    func test_retrieve_deliversFailureOnRetrievalError() {
        
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .failure(SUT.StoreError.emptyCache))
    }
    
    // useful for non-in-memory stores
    func test_retrieve_shouldHaveNoSideEffectsOnFailure() {
        
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .failure(SUT.StoreError.emptyCache))
    }
    
    func test_insert_shouldDeliverNoErrorOnNonEmptyCache() {
        
        let sut = makeSUT()
        
        let results = insert((makeModel(), .init()), to: sut)
        
        assertVoid(results, equalsTo: [.success(())])
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
        let sut = makeSUT()
        insert((makeModel(), .init()), to: sut)
        
        let insertionResults = insert((makeModel("other"), .init()), to: sut)
        
        assertVoid(insertionResults, equalsTo: [.success(())])
    }
    
    func test_insert_shouldOverridePreviouslyInsertedCacheValues() {
        
        let sut = makeSUT()
        
        insert((makeModel(), .init()), to: sut)
        
        let latestModel = makeModel("Latest Model")
        let latestValidUntil = Date()
        insert((latestModel, latestValidUntil), to: sut)
        
        expect(sut, toRetrieve: .success((latestModel, latestValidUntil)))
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
        let sut = makeSUT()
        
        let deletionResults = deleteCache(from: sut)
        
        assertVoid(deletionResults, equalsTo: [.success(())])
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
        let sut = makeSUT()
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .failure(SUT.StoreError.emptyCache))
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
        let sut = makeSUT()
        
        insert((makeModel(), .init()), to: sut)
        
        let deletionResults = deleteCache(from: sut)
        
        assertVoid(deletionResults, equalsTo: [.success(())])
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        insert((makeModel(), .init()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .failure(SUT.StoreError.emptyCache))
    }
    
    func test_storeSideEffects_runSerially() {
        
        let sut = makeSUT()
        
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(makeModel(), validUntil: .init()) { _ in
            
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCache { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(makeModel(), validUntil: .init()) { _ in
            
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order")
    }
    
    // MARK: - Helpers
    
    private typealias SUT = InMemoryStore<Model>
    
    private func makeSUT(
        initialValue: Cached<Model>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(initialValue: initialValue)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    @discardableResult
    private func insert(
        _ cache: Cached<Model>,
        to sut: SUT
    ) -> [SUT.InsertionResult] {
        
        let exp = expectation(description: "Wait for cache insertion")
        var insertionResults = [SUT.InsertionResult]()
        
        sut.insert(cache.0, validUntil: cache.validUntil) {
            
            insertionResults.append($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return insertionResults
    }
    
    @discardableResult
    private func deleteCache(
        from sut: SUT
    ) -> [SUT.DeletionResult] {
        
        let exp = expectation(description: "Wait for cache deletion")
        var deletionResults = [SUT.DeletionResult]()
        
        sut.deleteCache {
            
            deletionResults.append($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return deletionResults
    }
    
    private func expect(
        _ sut: SUT,
        toRetrieveTwice expectedResult: SUT.RetrievalResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(
        _ sut: SUT,
        toRetrieve expectedResult: SUT.RetrievalResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrieval")
        var receivedResults = [SUT.RetrievalResult]()
        
        sut.retrieve {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        assert(receivedResults, equalsTo: [expectedResult], file: file, line: line)
    }
    
    private func assert(
        _ receivedResults: [SUT.RetrievalResult],
        equalsTo expectedResults: [SUT.RetrievalResult],
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            receivedResults.count,
            expectedResults.count,
            "Received \(receivedResults.count) values, but expected \(expectedResults.count).",
            file: file, line: line
        )
        
        zip(receivedResults, expectedResults)
            .enumerated()
            .forEach { index, value in
                
                let (received, expected) = value
                
                switch (received, expected) {
                case let (
                    .failure(received as NSError),
                    .failure(expected as NSError)
                ):
                    XCTAssertEqual(received, expected, file: file, line: line)
                    
                case let (
                    .success((receivedModel, receivedValidUntil)),
                    .success((expectedModel, expectedValidUntil))
                ):
                    XCTAssertEqual(receivedModel, expectedModel, file: file, line: line)
                    XCTAssertEqual(receivedValidUntil, expectedValidUntil, file: file, line: line)
                    
                default:
                    XCTFail(
                        "\nReceived \(received) values, but expected \(expected) at index \(index).",
                        file: file, line: line
                    )
                }
            }
    }
}

private struct Model: Equatable {
    
    let value: String
    
    init(_ value: String) {
        
        self.value = value
    }
}

private func makeModel(
    _ value: String = "any model value"
) -> Model {
    
    .init(value)
}
