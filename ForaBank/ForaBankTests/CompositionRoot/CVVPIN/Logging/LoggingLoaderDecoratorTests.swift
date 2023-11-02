//
//  LoggingLoaderDecoratorTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.11.2023.
//

@testable import ForaBank
import XCTest

final class LoggingLoaderDecoratorTests: XCTestCase {
    
    func test_init_shouldNotMessageLogger() {
        
        let (_, spy) = makeSUT()
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_init_shouldLogLoadEmptyCache() {
        
        let (sut, spy) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.load { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            "LoaderDecorator<Item>: load failure: emptyCache."
        ])
    }
    
    func test_init_shouldLogSave() {
        
        let (sut, spy) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.save(anyItem(), validUntil: .init()) { _ in exp.fulfill() }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.messages, [
            "LoaderDecorator<Item>: save success."
        ])
    }
    
    func test_init_shouldLogInvalidLoadOnExpired() {

        let item = anyItem()
        let expired = Date()
        let currentDate = { expired.addingTimeInterval(1) }
        let (sut, spy) = makeSUT(currentDate: currentDate)
        let saveExp = expectation(description: "wait for save completion")
        let loadExp = expectation(description: "wait for load completion")

        sut.save(item, validUntil: expired) { _ in

            sut.load { _ in loadExp.fulfill() }
            saveExp.fulfill()
        }

        wait(for: [saveExp], timeout: 1.0)
        wait(for: [loadExp], timeout: 1.0)

        XCTAssertNoDiff(spy.messages, [
            "LoaderDecorator<Item>: save success.",
            "LoaderDecorator<Item>: load failure: invalidCache(validatedAt: \(currentDate()), validUntil: \(expired))."
        ])
    }
    
    func test_init_shouldLogLoadOnValid() {

        let item = anyItem()
        let validUntil = Date()
        let currentDate = { validUntil }
        let (sut, spy) = makeSUT(currentDate: currentDate)
        let saveExp = expectation(description: "wait for save completion")
        let loadExp = expectation(description: "wait for load completion")

        sut.save(item, validUntil: validUntil) { _ in

            sut.load { _ in loadExp.fulfill() }
            saveExp.fulfill()
        }

        wait(for: [saveExp], timeout: 1.0)
        wait(for: [loadExp], timeout: 1.0)

        XCTAssertNoDiff(spy.messages, [
            "LoaderDecorator<Item>: save success.",
            "LoaderDecorator<Item>: load success: Item(value: \"\(item.value)\")."
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
    
    private final class LogSpy {
        
        private(set) var messages = [String]()
        
        func log(_ message: String) {
            
            self.messages.append(message)
        }
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
            log: { message,_,_ in log(message) }
        )
    }
}
