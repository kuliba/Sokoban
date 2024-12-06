//
//  LoggingLoaderDecoratorTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 02.11.2023.
//

@testable import ForaBank
import XCTest

final class LoggingLoaderDecoratorTests: XCTestCase {
    
    func test_init_shouldNotMessageLogger() {
        
        let (_, spy, _) = makeSUT()
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_init_shouldLogLoadFailure() {
        
        let loadFailureMessage = "Retrieval Failure"
        let loadFailure = anyError(loadFailureMessage)
        let (sut, spy, loader) = makeSUT()
        
        load(sut, on: {
            
            loader.completeLoad(with: .failure(loadFailure))
        })
        
        XCTAssertNoDiff(spy.messages, [
            .init(.error, .cache, "LoaderDecorator<Item>: Load failure: \(loadFailureMessage).")
        ])
    }
    
    func test_init_shouldLogLoadSuccess() {
        
        let item = Item(value: "abc123")
        let (sut, spy, loader) = makeSUT()
        
        load(sut, on: {
            
            loader.completeLoad(with: .success(item))
        })
        
        XCTAssertNoDiff(spy.messages, [
            .init(.info, .cache, "LoaderDecorator<Item>: Load success: \(item).")
        ])
    }
    
    func test_init_shouldLogSaveFailure() {
        
        let saveFailureMessage = "Insertion Failure"
        let saveFailure = anyError(saveFailureMessage)
        let (sut, spy, loader) = makeSUT()
        
        save(sut, anyItem(), validUntil: .init(), on: {
            
            loader.completeSave(with: .failure(saveFailure))
        })
        
        XCTAssertNoDiff(spy.messages, [
            .init(.error, .cache, "LoaderDecorator<Item>: Save failure: \(saveFailureMessage).")
        ])
    }
    
    func test_init_shouldLogSaveSuccess() {
        
        let (sut, spy, loader) = makeSUT()
        
        save(sut, anyItem(), validUntil: .init(), on: {
            
            loader.completeSave(with: .success(()))
        })
        
        XCTAssertNoDiff(spy.messages, [
            .init(.info, .cache, "LoaderDecorator<Item>: Save success.")
        ])
    }
    
    func test_load_shouldNotLogOnInstanceDeallocation() {
        
        let spy = LogSpy()
        let loader = LoaderSpy<Item>()
        var sut: SUT? = SUT(
            decoratee: loader,
            log: spy.log
        )
        
        sut?.load { _ in }
        sut = nil
        loader.completeLoad(with: .success(anyItem()))
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    func test_save_shouldNotLogOnInstanceDeallocation() {
        
        let spy = LogSpy()
        let loader = LoaderSpy<Item>()
        var sut: SUT? = SUT(
            decoratee: loader,
            log: spy.log
        )
        
        sut?.save(anyItem(), validUntil: .init()) { _ in }
        sut = nil
        loader.completeSave(with: .success(()))
        
        XCTAssert(spy.messages.isEmpty)
    }
    
    // MARK: - Helperts
    
    private typealias SUT = LoggingLoaderDecorator<Item>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: LogSpy,
        loader: LoaderSpy<Item>
    ) {
        let spy = LogSpy()
        let loader = LoaderSpy<Item>()
        let sut = SUT(
            decoratee: loader,
            log: spy.log
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, spy, loader)
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
        log: @escaping (LoggerAgentLevel, String) -> Void
    ) {
        self.init(
            decoratee: decoratee,
            log: { level, message,_,_ in log(level, message) }
        )
    }
}
