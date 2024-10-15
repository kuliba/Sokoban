//
//  LoaderTests.swift
//  
//
//  Created by Igor Malyarov on 05.10.2023.
//

import GenericLoader
import XCTest

final class LoaderTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotMessageStore() {
        
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
        XCTAssertEqual(store.retrievalCompletions.count, 0)
        XCTAssertEqual(store.insertionCompletions.count, 0)
        XCTAssertEqual(store.deletionCompletions.count, 0)
    }
    
    // MARK: - load
    
    func test_load_shouldRequestStoreRetrieval() {
        
        let (sut, store) = makeSUT()
        XCTAssertEqual(store.retrievalCompletions.count, 0)
        
        sut.load { _ in }
        
        XCTAssertEqual(store.retrievalCompletions.count, 1)
    }
    
    func test_load_shouldDeliverLoadFailureOnEmptyCacheRetrievalFailure() {
        
        let (sut, store) = makeSUT()
        
        assertLoad(sut, delivers: .failure(anyError("Empty Cache Error")), on: {
            
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_load_shouldDeliverLoadFailureOnStoreRetrievalFailure() {
        
        let retrieveError = anyError("Retrieval Failure")
        let (sut, store) = makeSUT()
        
        assertLoad(sut, delivers: .failure(retrieveError), on: {
            
            store.completeRetrieval(with: retrieveError)
        })
    }
    
    func test_load_shouldDeliverInvalidCacheErrorOnExpiredCache() {
        
        let fixedCurrentDate = Date()
        let expiredAt = expired(against: fixedCurrentDate)
        let expiredCache = (anyLocal(), expiredAt)
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        
        assertLoad(sut, delivers: .failure(SUT.LoadError.invalidCache(validatedAt: fixedCurrentDate, validUntil: expiredAt)), on: {
            
            store.completeRetrieval(with: expiredCache)
        })
    }
    
    func test_load_shouldSucceedOnExpirationCache() {
        
        let fixedCurrentDate = Date()
        let expirationCache = (
            anyLocal("abc123"),
            expiration(against: fixedCurrentDate)
        )
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        
        assertLoad(sut, delivers: .success(.init("abc123")), on: {
            
            store.completeRetrieval(with: expirationCache)
        })
    }
    
    func test_load_shouldSucceedOnNonExpiredCache() {
        
        let fixedCurrentDate = Date()
        let nonExpiredCache = (
            anyLocal("abc123"),
            nonExpired(against: fixedCurrentDate)
        )
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        
        assertLoad(sut, delivers: .success(.init("abc123")), on: {
            
            store.completeRetrieval(with: nonExpiredCache)
        })
    }
    
    func test_load_shouldHaveNoSideEffectsOnRetrievalError() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyError())
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_shouldHaveNoSideEffectsOnEmptyCache() {
        
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_shouldHaveNoSideEffectsOnExpiredCache() {
        
        let fixedCurrentDate = Date()
        let expiredCache = (
            anyLocal("abc123"),
            expired(against: fixedCurrentDate)
        )
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        
        sut.load { _ in }
        store.completeRetrieval(with: expiredCache)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_shouldHaveNoSideEffectsOnCacheExpiration() {
        
        let fixedCurrentDate = Date()
        let expirationCache = (
            anyLocal("abc123"),
            expiration(against: fixedCurrentDate)
        )
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        
        sut.load { _ in }
        store.completeRetrieval(with: expirationCache)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_shouldHaveNoSideEffectsOnNonExpiredCache() {
        
        let fixedCurrentDate = Date()
        let nonExpiredCache = (
            anyLocal("abc123"),
            nonExpired(against: fixedCurrentDate)
        )
        let (sut, store) = makeSUT(currentDate: fixedCurrentDate)
        
        sut.load { _ in }
        store.completeRetrieval(with: nonExpiredCache)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    // MARK: - save
    
    func test_save_shouldNotRequestCacheInsertionOnDeletionError() {
        
        let deletionError = anyError("Cache Deletion Failure")
        let model = anyModel()
        let (sut, store) = makeSUT()
        
        sut.save(model, validUntil: .init()) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.messages, [.delete])
    }
    
    func test_save_shouldRequestsNewCacheInsertionWithValidUntilOnSuccessfulDeletion() {
        
        let validUntil = Date()
        let model = anyModel()
        let (sut, store) = makeSUT()
        
        sut.save(model, validUntil: validUntil) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [
            .delete,
            .insert(toLocal(model), validUntil)
        ])
    }
    
    func test_save_shouldDeliverErrorOnCacheDeletionError() {
        
        let deletionError = anyError("Cache Deletion Failure")
        let (sut, store) = makeSUT()
        
        assertSave(sut, delivers: .failure(deletionError), on: {
            
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_shouldDeliverErrorOnInsertionError() {
        
        let insertionError = anyError("Insertion Failure")
        let (sut, store) = makeSUT()
        
        assertSave(sut, delivers: .failure(insertionError), on: {
            
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_shouldSucceedOnSuccessfulCacheInsertion() {
        
        let (sut, store) = makeSUT()
        
        assertSave(sut, delivers: .success(()), on: {
            
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    // MARK: - instance deallocation
    
    func test_load_shouldNotDeliverResultOnInstanceDeallocation() {
        
        let store = StoreSpy<TestLocal>()
        var sut: SUT? = .init(
            store: store,
            toModel: { .init($0.value) },
            toLocal: toLocal
        )
        var results = [SUT.LoadResult]()
        
        sut?.load { results.append($0) }
        sut = nil
        store.completeRetrieval(with: (anyLocal(), .init()))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_save_shouldNotDeliverResultOnInstanceDeallocation() {
        
        let store = StoreSpy<TestLocal>()
        var sut: SUT? = .init(
            store: store,
            toModel: { .init($0.value) },
            toLocal: toLocal
        )
        var results = [SUT.SaveResult]()
        
        sut?.save(anyModel(), validUntil: .init()) { results.append($0) }
        sut = nil
        store.completeDeletionSuccessfully()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertTrue(results.isEmpty)
    }
    
    func test_save_shouldNotDeliverResultOnInstanceDeallocationAfterDelete() {
        
        let store = StoreSpy<TestLocal>()
        var sut: SUT? = .init(
            store: store,
            toModel: { .init($0.value) },
            toLocal: toLocal
        )
        var results = [SUT.SaveResult]()
        
        sut?.save(anyModel(), validUntil: .init()) { results.append($0) }
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertionSuccessfully()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertTrue(results.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Loader<Model, TestLocal>
    
    private func makeSUT(
        currentDate: Date = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        store: StoreSpy<TestLocal>
    ) {
        let store = StoreSpy<TestLocal>()
        let sut = SUT(
            store: store,
            toModel: { .init($0.value) },
            toLocal: toLocal,
            currentDate: { currentDate }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func toLocal(_ model: Model) -> TestLocal {
        
        .init(model.value)
    }
    
    private func expired(
        against currentDate: Date = .init()
    ) -> Date {
        
        currentDate.addingTimeInterval(-1)
    }
    
    private func expiration(
        against currentDate: Date = .init()
    ) -> Date {
        
        currentDate
    }
    
    private func nonExpired(
        against currentDate: Date = .init()
    ) -> Date {
        
        currentDate.addingTimeInterval(1)
    }
    
    private func assertLoad(
        _ sut: SUT,
        delivers expectedResult: SUT.LoadResult,
        on action: @escaping () -> Void,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        var receivedResults = [SUT.LoadResult]()
        
        sut.load {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
        
        assertLoadResults(receivedResults, equalsTo: [expectedResult], message(), file: file, line: line)
    }
    
    private func assertLoadResults(
        _ receivedResults: [SUT.LoadResult],
        equalsTo expectedResults: [SUT.LoadResult],
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
                    .failure(SUT.LoadError.invalidCache(
                        validatedAt: receivedValidatedAt,
                        validUntil: receivedValidUntil
                    )),
                    .failure(SUT.LoadError.invalidCache(
                        validatedAt: expectedValidatedAt,
                        validUntil: expectedValidUntil
                    ))
                ):
                    XCTAssertEqual(receivedValidatedAt, expectedValidatedAt, file: file, line: line)
                    XCTAssertEqual(receivedValidUntil, expectedValidUntil, file: file, line: line)
                    
                case let (
                    .failure(received as NSError),
                    .failure(expected as NSError)
                ):
                    XCTAssertEqual(received, expected, file: file, line: line)
                    
                case let (
                    .success(received),
                    .success(expected)
                ):
                    XCTAssertEqual(received, expected, file: file, line: line)
                    
                default:
                    XCTFail(
                        "\nReceived \(received) values, but expected \(expected) at index \(index).",
                        file: file, line: line
                    )
                }
            }
    }
    
    private func assertSave(
        _ sut: SUT,
        delivers expectedResult: SUT.SaveResult,
        on action: @escaping () -> Void,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        var receivedResults = [SUT.SaveResult]()
        
        sut.save(anyModel(), validUntil: .init()) {
            
            receivedResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.1)
        
        assertVoid(receivedResults, equalsTo: [expectedResult], message(), file: file, line: line)
    }
}

private struct Model: Equatable {
    
    let value: String
    
    init(_ value: String) {
        
        self.value = value
    }
}

private func anyModel(
    _ value: String = "any model value"
) -> Model {
    
    .init(value)
}

private struct TestLocal: Equatable {
    
    let value: String
    
    init(_ value: String) {
        
        self.value = value
    }
}

private func anyLocal(
    _ value: String = "any local value"
) -> TestLocal {
    
    .init(value)
}
