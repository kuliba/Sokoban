//
//  CodableSessionCodeStoreTests.swift
//  
//
//  Created by Igor Malyarov on 14.07.2023.
//

import CvvPin
import XCTest

final class CodableSessionCodeStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStore()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    typealias StoreError = CodableSessionCodeStore.Error
    
    func test_retrieve_shouldDeliverErrorOnEmptyCache() {
        
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .failure(StoreError.retrieveFailure))
    }
    
    func test_retrieveTwice_shouldDeliverErrorOnEmptyCacheTwice() {
        
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .failure(StoreError.retrieveFailure))
        expect(sut, toRetrieve: .failure(StoreError.retrieveFailure))
    }
    
    func test_retrieve_shouldDeliverInsertedValuesAfterInsertingToEmptyCache() {
        
        let sut = makeSUT()
        let localSessionCode = uniqueSessionCode().local
        let timestamp = Date()
        
        insert(localSessionCode, with: timestamp, to: sut)
        
        expect(sut, toRetrieve: .success((localSessionCode, timestamp)))
    }
    
    func test_retrieve_shouldHaveNoSideEffectsOnNonEmptyCache() {
        
        let sut = makeSUT()
        let localSessionCode = uniqueSessionCode().local
        let timestamp = Date()
        
        insert(localSessionCode, with: timestamp, to: sut)
        
        expect(sut, toRetrieve: .success((localSessionCode, timestamp)))
        expect(sut, toRetrieve: .success((localSessionCode, timestamp)))
    }
    
    func test_retrieve_shouldDeliverErrorOnRetrievalError() {
        
        let storeURL = testStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".data(using: .utf8)?.write(to: storeURL)
        
        expect(sut, toRetrieve: .failure(StoreError.retrieveFailure))
    }
    
    func test_retrieve_shouldHaveNoSideEffectsOnRetrievalError() {
        
        let storeURL = testStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".data(using: .utf8)?.write(to: storeURL)
        
        expect(sut, toRetrieve: .failure(StoreError.retrieveFailure))
        expect(sut, toRetrieve: .failure(StoreError.retrieveFailure))
    }
    
    func test_insert_shouldOverridePreviouslyInsertedData() {
        
        let sut = makeSUT()
        let firstSessionCode = uniqueSessionCode().local
        let firstTimestamp = Date()
        
        let firstInsertionError = insert(firstSessionCode, with: firstTimestamp, to: sut)
        
        XCTAssertNil(firstInsertionError, "Expected successful insertion.")
        expect(sut, toRetrieve: .success((firstSessionCode, firstTimestamp)))
        
        let secondSessionCode = uniqueSessionCode().local
        let secondTimestamp = Date()
        
        let secondInsertionError = insert(secondSessionCode, with: secondTimestamp, to: sut)
        
        XCTAssertNil(secondInsertionError, "Expected successful cache override.")
        expect(sut, toRetrieve: .success((secondSessionCode, secondTimestamp)))
    }
    
    func test_insert_shouldDeliverErrorOnInsertionError() {
        
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        let insertionError = insert(uniqueSessionCode().local, with: .init(), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_insert_shouldHaveNoSideEffectsOnInsertionError() {
        
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        insert(uniqueSessionCode().local, with: .init(), to: sut)
        
        expect(sut, toRetrieve: .failure(StoreError.retrieveFailure))
    }
    
    func test_delete_shouldNotDeliverErrorOnEmptyCacheDeletion() {
        
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected successful empty cache deletion.")
    }
    
    func test_delete_shouldHaveNoSideEffectsOnEmptyCache() {
        
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .failure(StoreError.retrieveFailure))
    }
    
    func test_delete_shouldNotDeliverErrorOnNonEmptyCacheDeletion() {
        
        let sut = makeSUT()
        insert(uniqueSessionCode().local, with: .init(), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected successful non-empty cache deletion.")
    }
    
    func test_delete_shouldRemovePreviouslyInsertedCache() {
        
        let sut = makeSUT()
        insert(uniqueSessionCode().local, with: .init(), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .failure(StoreError.retrieveFailure))
    }
    
    func test_delete_shouldDeliverErrorOnDeletionError() {
        
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_delete_shouldNotHaveSideEffectsOnDeletionError() {
        
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .failure(StoreError.retrieveFailure))
    }
    
    func test_storeSideEffects_shouldRunSerially() {
        
        let sut = makeSUT()
        var operations = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueSessionCode().local, timestamp: .init()) { _ in
            operations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedSessionCode { _ in
            operations.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueSessionCode().local, timestamp: .init()) { _ in
            operations.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(operations, [op1, op2, op3])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        storeURL: URL? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SessionCodeStore {
        
        let sut = CodableSessionCodeStore(storeURL: storeURL ?? testStoreURL())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(
        _ sut: SessionCodeStore,
        toRetrieve expectedResult: SessionCodeStore.RetrievalResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for retrieval")
        
        sut.retrieve { retrievedResult in
            
            switch (expectedResult, retrievedResult) {
            case let (.success(expected), .success(retrieve)):
                XCTAssertEqual(expected.0, retrieve.0, file: file, line: line)
                XCTAssertEqual(expected.1, retrieve.1, file: file, line: line)
                
            case let (.failure(expected as NSError?), .failure(retrieved as NSError?)):
                XCTAssertEqual(expected, retrieved, file: file, line: line)
                
            default:
                XCTFail("Expected retrieving \(expectedResult), got \(retrievedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
    private func insert(
        _ localSessionCode: LocalSessionCode,
        with timestamp: Date,
        to sut: SessionCodeStore
    ) -> Error? {
        
        let exp = expectation(description: "Wait for cache insertion")
        
        var error: Error?
        sut.insert(localSessionCode, timestamp: timestamp) {
            
            if case let .failure(insertionError) = $0 {
                error = insertionError
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return error
    }
    
    @discardableResult
    private func deleteCache(
        from sut: SessionCodeStore
    ) -> Error? {
        
        let exp = expectation(description: "Wait for cache deletion")
        
        var error: Error?
        sut.deleteCachedSessionCode {
            
            if case let .failure(deletionError) = $0 {
                error = deletionError
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return error
    }
    
    private func testStoreURL() -> URL {
        
        cachesDirectory()
            .appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func noDeletePermissionURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
    
    private func setupEmptyStore() {
        
        removeStoreArtefacts()
    }
    
    private func undoStoreSideEffects() {
        
        removeStoreArtefacts()
    }
    
    private func removeStoreArtefacts() {
        
        try? FileManager.default.removeItem(at: testStoreURL())
    }
}
