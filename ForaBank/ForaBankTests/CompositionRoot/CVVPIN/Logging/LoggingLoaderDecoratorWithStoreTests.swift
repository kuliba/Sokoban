//
//  LoggingLoaderDecoratorTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.11.2023.
//

@testable import ForaBank
import XCTest

final class LoggingLoaderDecoratorWithStoreTests: XCTestCase {
    
    func test_init_shouldNotMessageLogger() {
        
        let (_, spy, _) = makeSUT()
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_init_shouldLogLoadFailure() {
        
        let retrievalFailureMessage = "Retrieval Failure"
        let retrievalFailure = anyError(retrievalFailureMessage)
        let (sut, spy, store) = makeSUT()
        
        load(sut, on: {
            
            store.completeRetrieval(with: retrievalFailure)
        })
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, "LoaderDecorator<Item>: Load failure: \(retrievalFailureMessage).")
        ])
    }
    
    func test_init_shouldLogLoadSuccess() {
        
        let item = Item(value: "abc123")
        let validUntil = Date()
        let (sut, spy, store) = makeSUT(currentDate: { validUntil })
        
        load(sut, on: {
            
            store.completeRetrieval(with: (item, validUntil))
        })
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, "LoaderDecorator<Item>: Load success: \(item).")
        ])
    }
    
    func test_init_shouldLogSaveFailure() {
        
        let insertionFailureMessage = "Insertion Failure"
        let insertionFailure = anyError(insertionFailureMessage)
        let (sut, spy, store) = makeSUT()
        
        save(sut, anyItem(), validUntil: .init(), on: {
            
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionFailure)
        })
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, "LoaderDecorator<Item>: Save failure: \(insertionFailureMessage).")
        ])
    }
    
    func test_init_shouldLogDeletionFailure() {
        
        let deletionFailureMessage = "Insertion Failure"
        let deletionFailure = anyError(deletionFailureMessage)
        let (sut, spy, store) = makeSUT()
        
        save(sut, anyItem(), validUntil: .init(), on: {
            
            store.completeDeletion(with: deletionFailure)
        })
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, "LoaderDecorator<Item>: Save failure: \(deletionFailureMessage).")
        ])
    }
    
    func test_init_shouldLogSaveSuccess() {
        
        let (sut, spy, store) = makeSUT()
        
        save(sut, anyItem(), validUntil: .init(), on: {
            
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, "LoaderDecorator<Item>: Save success.")
        ])
    }
    
    func test_load_shouldNotLogOnInstanceDeallocation() {
    
        let spy = LogSpy()
        let store = StoreSpy<Item>()
        let loader = GenericLoaderOf<Item>(store: store)
        var sut: SUT? = SUT(
            decoratee: loader,
            log: spy.log
        )

        sut?.load { _ in }
        sut = nil
        store.completeRetrieval(with: (anyItem(), .init()))
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_save_shouldNotLogOnInstanceDeallocation() {
    
        let spy = LogSpy()
        let store = StoreSpy<Item>()
        let loader = GenericLoaderOf<Item>(store: store)
        var sut: SUT? = SUT(
            decoratee: loader,
            log: spy.log
        )

        sut?.save(anyItem(), validUntil: .init()) { _ in }
        sut = nil
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    // MARK: - Helperts
    
    private typealias SUT = LoggingLoaderDecorator<Item>
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LogSpy,
        store: StoreSpy<Item>
    ) {
        let spy = LogSpy()
        let store = StoreSpy<Item>()
        let loader = GenericLoaderOf<Item>(
            store: store,
            currentDate: currentDate
        )
        let sut = SUT(
            decoratee: loader,
            log: spy.log
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, spy, store)
    }
    
    private func load(
        _ sut: SUT,
        on action: @escaping () -> Void
    ) {
        
        let exp = expectation(description: "wait for completion")
        
        sut.load { _ in exp.fulfill() }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(
        _ sut: SUT,
        _ item: Item,
        validUntil: Date,
        on action: @escaping () -> Void
    ) {
        
        let exp = expectation(description: "wait for completion")
        
        sut.save(item, validUntil: validUntil) { _ in
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func anyItem(
        value: String = UUID().uuidString
    ) -> Item {
        
        .init(value: value)
    }
    
    struct Item {
        
        let value: String
    }
    
    private func anyError(_ message: String = "any error") -> Error {
        
        AnyError(message: message)
    }
    
    private struct AnyError: Error, CustomStringConvertible {
        
        let message: String
        
        var description: String { message }
    }
}

private extension LoggingLoaderDecorator {
    
    convenience init(
        decoratee: any Loader<T>,
        log: @escaping (String) -> Void
    ) {
        self.init(
            decoratee: decoratee,
            log: { _, message,_,_ in log(message) }
        )
    }
}
