//
//  LoggingStoreDecoratorTests.swift
//  
//
//  Created by Igor Malyarov on 07.10.2023.
//

import CVVPINServices
import XCTest

final class LoggingStoreDecoratorTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotMessageStore() {
        
        let (_, storeSpy, _) = makeSUT()
        
        XCTAssertEqual(storeSpy.messages, [])
    }
    
    func test_init_shouldNotMessageLog() {
        
        let (_, _, logSpy) = makeSUT()
        
        XCTAssertEqual(logSpy.messages, [])
    }
    
    // MARK: - retrieve
    
    func test_retrieve_shouldLogRetrievalFailure() {
        
        let retrievalError = anyError("Retrieval Failure")
        let (sut, storeSpy, logSpy) = makeSUT()
        
        _ = retrievalResults(sut, on: {
            
            storeSpy.completeRetrieval(with: retrievalError)
        })
        
        XCTAssertEqual(logSpy.messages, [
            "Retrieve requested.",
            "Retrieval failure: \(retrievalError)."
        ])
    }
    
    func test_retrieve_shouldLogRetrievalSuccess() {
        
        let local = uniqueLocal()
        let validUntil = Date()
        let (sut, storeSpy, logSpy) = makeSUT()
        
        _ = retrievalResults(sut, on: {
            
            storeSpy.completeRetrieval(with: (local, validUntil))
        })
        
        XCTAssertEqual(logSpy.messages, [
            "Retrieve requested.",
            "Retrieval success with \(local) valid until \(validUntil)."
        ])
    }
    
    // MARK: - insert
    
    func test_insert_shouldLogInsertionFailure() {
        
        let local = uniqueLocal()
        let validUntil = Date()
        let insertionError = anyError("Insertion Failure")
        let (sut, storeSpy, logSpy) = makeSUT()
        
        _ = insertionResults(sut, local: local, validUntil: validUntil, on: {
            
            storeSpy.completeInsertion(with: insertionError)
        })
        
        XCTAssertEqual(logSpy.messages, [
            "Requested insert of \(local) valid until \(validUntil).",
            "Insertion failure: \(insertionError)."
        ])
    }
    
    func test_insert_shouldLogInsertionSuccess() {
        
        let local = uniqueLocal()
        let validUntil = Date()
        let (sut, storeSpy, logSpy) = makeSUT()
        
        _ = insertionResults(sut, local: local, validUntil: validUntil, on: {
            
            storeSpy.completeInsertionSuccessfully()
        })
        
        XCTAssertEqual(logSpy.messages, [
            "Requested insert of \(local) valid until \(validUntil).",
            "Insertion success with \(local) valid until \(validUntil)."
        ])
    }
    
    // MARK: - delete cache
    
    func test_deleteCache_shouldLogDeletionFailure() {
        
        let deletionError = anyError("Deletion Failure")
        let (sut, storeSpy, logSpy) = makeSUT()
        
        _ = deletionResults(sut, on: {
            
            storeSpy.completeDeletion(with: deletionError)
        })
        
        XCTAssertEqual(logSpy.messages, [
            "Requested cache deletion.",
            "Cache deletion failure: \(deletionError)."
        ])
    }
    
    func test_deleteCache_shouldLogDeletionSuccess() {
        
        let (sut, storeSpy, logSpy) = makeSUT()
        
        _ = deletionResults(sut, on: {
            
            storeSpy.completeDeletionSuccessfully()
        })
        
        XCTAssertEqual(logSpy.messages, [
            "Requested cache deletion.",
            "Cache deletion success."
        ])
    }
    
    // MARK: - instance deallocation
    
    func test_retrieve_shouldNotLogRetrievalResultOnInstanceDeallocation() {
        
        let retrievalError = anyError("Retrieval Failure")
        let storeSpy = StoreSpy<TestLocal>()
        let logSpy = LogSpy()
        var sut: SUT? = .init(decoratee: storeSpy, log: logSpy.log)
        var retrievalResults = [SUT.RetrievalResult]()
        
        sut?.retrieve { retrievalResults.append($0) }
        sut = nil
        storeSpy.completeRetrieval(with: retrievalError)
        
        XCTAssertEqual(logSpy.messages, [
            "Retrieve requested."
        ])
    }
    
    func test_insert_shouldNotLogInsertionResultOnInstanceDeallocation() {
        
        let local = uniqueLocal()
        let validUntil = Date()
        let insertionError = anyError("Insertion Failure")
        let storeSpy = StoreSpy<TestLocal>()
        let logSpy = LogSpy()
        var sut: SUT? = .init(decoratee: storeSpy, log: logSpy.log)
        var insertionResults = [SUT.InsertionResult]()
        
        sut?.insert(local, validUntil: validUntil) { insertionResults.append($0) }
        sut = nil
        storeSpy.completeInsertion(with: insertionError)
        
        XCTAssertEqual(logSpy.messages, [
            "Requested insert of \(local) valid until \(validUntil)."
        ])
    }
    
    func test_deleteCache_shouldNotLogDeleteCacheResultOnInstanceDeallocation() {
        
        let deletionError = anyError("Deletion Failure")
        let storeSpy = StoreSpy<TestLocal>()
        let logSpy = LogSpy()
        var sut: SUT? = .init(decoratee: storeSpy, log: logSpy.log)
        var deletionResults = [SUT.DeletionResult]()
        
        sut?.deleteCache { deletionResults.append($0) }
        sut = nil
        storeSpy.completeDeletion(with: deletionError)
        
        XCTAssertEqual(logSpy.messages, [
            "Requested cache deletion."
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoggingStoreDecorator<TestLocal>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        storeSpy: StoreSpy<TestLocal>,
        logSpy: LogSpy
    ) {
        let storeSpy = StoreSpy<TestLocal>()
        let logSpy = LogSpy()
        let sut = SUT(decoratee: storeSpy, log: logSpy.log)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(storeSpy, file: file, line: line)
        trackForMemoryLeaks(logSpy, file: file, line: line)
        
        return (sut, storeSpy, logSpy)
    }
    
    private final class LogSpy {
        
        private(set) var messages = [String]()
        
        func log(message: String) -> Void {
            
            messages.append(message)
        }
    }
    
    private func retrievalResults(
        _ sut: SUT,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> [SUT.RetrievalResult] {
        
        let exp = expectation(description: "wait for completion")
        var retrievalResults = [SUT.RetrievalResult]()
        
        sut.retrieve {
            
            retrievalResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        return retrievalResults
    }
    
    private func deletionResults(
        _ sut: SUT,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> [SUT.DeletionResult] {
        
        let exp = expectation(description: "wait for completion")
        var retrievalResults = [SUT.DeletionResult]()
        
        sut.deleteCache {
            
            retrievalResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        return retrievalResults
    }
    
    private func insertionResults(
        _ sut: SUT,
        local: TestLocal,
        validUntil: Date,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) -> [SUT.InsertionResult] {
        
        let exp = expectation(description: "wait for completion")
        var insertionResults = [SUT.InsertionResult]()
        
        sut.insert(
            local,
            validUntil: validUntil
        ) {
            insertionResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        return insertionResults
    }
}

private struct TestLocal: Equatable {
    
    let value: String
    
    init(_ value: String) {
        
        self.value = value
    }
}

private func uniqueLocal(
    _ value: String = UUID().uuidString
) -> TestLocal {
    
    .init(value)
}
