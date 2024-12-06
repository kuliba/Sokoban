//
//  LoggingLoaderDecoratorWithInMemoryStoreTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 02.11.2023.
//

@testable import ForaBank
import XCTest

final class LoggingLoaderDecoratorWithInMemoryStoreTests: XCTestCase {
    
    func test_init_shouldNotMessageLogger() {
        
        let (_, spy) = makeSUT()
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_init_shouldLogLoadEmptyCache() {
        
        let (sut, spy) = makeSUT()
        
        load(sut)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, "LoaderDecorator<Item>: Load failure: emptyCache.")
        ])
    }
    
    func test_init_shouldLogSave() {
        
        let (sut, spy) = makeSUT()
        
        save(sut, anyItem(), validUntil: .init())
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, "LoaderDecorator<Item>: Save success.")
        ])
    }
    
    func test_init_shouldLogInvalidLoadOnExpired() {
        
        let item = anyItem()
        let expired = Date()
        let currentDate = { expired.addingTimeInterval(1) }
        let (sut, spy) = makeSUT(currentDate: currentDate)
        
        save(sut, item, validUntil: expired)
        load(sut)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, "LoaderDecorator<Item>: Save success."),
            .init(.debug, .cache, "LoaderDecorator<Item>: Load failure: invalidCache(validatedAt: \(currentDate()), validUntil: \(expired)).")
        ])
    }
    
    func test_init_shouldLogLoadOnValid() {
        
        let item = anyItem()
        let validUntil = Date()
        let currentDate = { validUntil }
        let (sut, spy) = makeSUT(currentDate: currentDate)
        
        save(sut, item, validUntil: validUntil)
        load(sut)
        
        XCTAssertNoDiff(spy.messages, [
            .init(.debug, .cache, "LoaderDecorator<Item>: Save success."),
            .init(.debug, .cache, "LoaderDecorator<Item>: Load success: \(item).")
        ])
    }
    
    // MARK: - Helperts
    
    private typealias SUT = LoggingLoaderDecorator<Item>
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LogSpy
    ) {
        let spy = LogSpy()
        let store = InMemoryStore<Item>()
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
        
        return (sut, spy)
    }
    
    private func load(_ sut: SUT) {
        
        let exp = expectation(description: "wait for completion")
        
        sut.load { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ sut: SUT, _ item: Item, validUntil: Date) {
        
        let exp = expectation(description: "wait for completion")
        
        sut.save(item, validUntil: validUntil) { _ in
            
            exp.fulfill()
        }
        
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
