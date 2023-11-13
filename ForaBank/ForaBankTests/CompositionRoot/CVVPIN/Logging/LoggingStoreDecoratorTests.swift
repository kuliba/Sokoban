//
//  LoggingStoreDecoratorTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.11.2023.
//

@testable import ForaBank
import XCTest

final class LoggingStoreDecoratorTests: XCTestCase {
    
    func test_init_shouldNotMessageLog() {
        
        let (_, spy, _) = makeSUT()
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_retrieve_shouldLogOnSuccess() throws {
        
        let item = anyItem()
        let validUntil = Date()
        let (sut, spy, store) = makeSUT()
        
        retrieve(sut, on: {
            
            store.completeRetrieval(with: (item, validUntil))
        })
        
        try assertIsOne(in: spy.messages, .info, contains: "Retrieval success: \(item) valid until \(validUntil).")
    }
    
    func test_retrieve_shouldLogOnFailure() throws {
        
        let retrievalError = anyError("Retrieval Failure")
        let (sut, spy, store) = makeSUT()
        
        retrieve(sut, on: {
            
            store.completeRetrieval(with: retrievalError)
        })
        
        try assertIsOne(in: spy.messages, .error, contains: "Retrieval failure")
    }
    
    func test_retrieve_shouldNotLogOnInstanceDeallocation() throws {
        
        let spy = LogSpy()
        let store = StoreSpy<Item>()
        var sut: SUT? = SUT(decoratee: store, log: spy.log)
        
        sut?.retrieve { _ in }
        sut = nil
        store.completeRetrieval(with: (anyItem(), .init()))
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_insert_shouldLogOnSuccess() throws {
        
        let item = anyItem()
        let validUntil = Date()
        let (sut, spy, store) = makeSUT()
        
        insert(sut, item, validUntil: validUntil, on: {
            
            store.completeInsertionSuccessfully()
        })
        
        try assertIsOne(in: spy.messages, .info, contains: "Insertion success: \(item) validUntil \(validUntil).")
    }
    
    func test_insert_shouldLogOnFailure() throws {
        
        let item = anyItem()
        let validUntil = Date()
        let insertionError = anyError("Insertion Failure")
        let (sut, spy, store) = makeSUT()
        
        insert(sut, item, validUntil: validUntil, on: {
            
            store.completeInsertion(with: insertionError)
        })
        
        try assertIsOne(in: spy.messages, .error, contains: "Insertion failure: \(item) validUntil \(validUntil): ")
    }
    
    func test_insert_shouldNotLogOnInstanceDeallocation() throws {
        
        let spy = LogSpy()
        let store = StoreSpy<Item>()
        var sut: SUT? = SUT(decoratee: store, log: spy.log)
        
        sut?.insert(anyItem(), validUntil: .init()) { _ in }
        sut = nil
        store.completeInsertionSuccessfully()
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_deleteCache_shouldLogOnSuccess() throws {
        
        let (sut, spy, store) = makeSUT()
        
        deleteCache(sut, on: {
            
            store.completeDeletionSuccessfully()
        })
        
        try assertIsOne(in: spy.messages, .info, contains: "Cache deletion success")
    }
    
    func test_deleteCache_shouldLogOnFailure() throws {
        
        let deleteCacheError = anyError("Cache Deletion Failure")
        let (sut, spy, store) = makeSUT()
        
        deleteCache(sut, on: {
            
            store.completeDeletion(with: deleteCacheError)
        })
        
        try assertIsOne(in: spy.messages, .error, contains: "Cache deletion failure: ")
    }
    
    func test_deleteCache_shouldNotLogOnInstanceDeallocation() throws {
        
        let spy = LogSpy()
        let store = StoreSpy<Item>()
        var sut: SUT? = SUT(decoratee: store, log: spy.log)
        
        sut?.deleteCache { _ in }
        sut = nil
        store.completeDeletionSuccessfully()
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoggingStoreDecorator<Item>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LogSpy,
        store: StoreSpy<Item>
    ) {
        let spy = LogSpy()
        let store = StoreSpy<Item>()
        let sut = SUT(decoratee: store, log: spy.log)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, spy, store)
    }
    
    private func retrieve(
        _ sut: SUT,
        on action: @escaping () -> Void
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.retrieve { _ in exp.fulfill() }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func insert(
        _ sut: SUT,
        _ item: Item,
        validUntil: Date,
        on action: @escaping () -> Void
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.insert(item, validUntil: validUntil) { _ in
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func deleteCache(
        _ sut: SUT,
        on action: @escaping () -> Void
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.deleteCache { _ in exp.fulfill() }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func assertIsOne(
        in messages: [LogSpy.Message],
        _ level: LoggerAgentLevel,
        contains text: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        XCTAssertNoDiff(messages.count, 1, "Expected one message, but got \(messages.count)", file: file, line: line)
        
        let message = try XCTUnwrap(messages.first)
        XCTAssertNoDiff(message.level, level, file: file, line: line)
        XCTAssert(message.text.contains(text))
    }
    
    private func anyItem(
        value: String = UUID().uuidString
    ) -> Item {
        
        .init(value: value)
    }
    
    private struct Item {
        
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

private extension LoggingStoreDecorator {
    
    convenience init(
        decoratee: any Store<T>,
        log: @escaping (LoggerAgentLevel, String) -> Void
    ) {
        self.init(
            decoratee: decoratee,
            log: { level, message,_,_ in log(level, message) }
        )
    }
}
