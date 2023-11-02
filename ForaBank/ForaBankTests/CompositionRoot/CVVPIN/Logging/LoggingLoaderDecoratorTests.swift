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
    
    // MARK: - Helperts
    
    private typealias SUT = LoggingLoaderDecorator<Item>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LogSpy
    ) {
        let spy = LogSpy()
        let store = InMemoryStore<Item>()
        let loader = GenericLoaderOf<Item>(store: store)
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
