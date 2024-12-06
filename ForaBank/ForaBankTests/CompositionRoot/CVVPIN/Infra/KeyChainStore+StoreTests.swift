//
//  KeyChainStore+StoreTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 02.11.2023.
//

@testable import ForaBank
import KeyChainStore
import XCTest

final class KeyChainStore_StoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStore()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieve_shouldDeliverFailureOnEmptyStore() throws {
        
        XCTAssertThrowsError(
            try retrieve(makeSUT())?.get()
        )
    }
    
    func test_retrieve_shouldDeliverValueAfterInsertion() throws {
        
        let sut = makeSUT()
        
        try insert(sut, anyItem())?.get()
        XCTAssertNoThrow(
            try retrieve(sut)?.get()
        )
    }
    
    func test_retrieve_shouldDeliverSameValueAfterInsertion() throws {
        
        let sut1 = makeSUT()
        let sut2 = makeSUT()
        
        try insert(sut1, anyItem())?.get()
        let value1 = try XCTUnwrap(retrieve(sut1)?.get())
        let value2 = try XCTUnwrap(retrieve(sut2)?.get())
        
        XCTAssertEqual(value1.0, value2.0)
        XCTAssertEqual(value1.1, value2.1)
    }
    
    func test_retrieve_shouldDeliverFailureAfterDeleteCache() throws {
        
        let sut = makeSUT()
        
        try insert(sut, anyItem())?.get()
        try deleteCache(sut)?.get()
        
        XCTAssertThrowsError(
            try retrieve(sut)?.get()
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = KeyChainStore<Tag, Item>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            keyTag: .init(rawValue: "test tag"),
            data: { .init($0.value.utf8) },
            key: {
                guard let value = String(data: $0, encoding: .utf8)
                else {
                    throw DataToStringConversionError()
                }
                
                return .init(value: value)
            }
        )
        
        // TODO: restore memory tracking after solving tearDown
        // trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private struct DataToStringConversionError: Error {}
    
    @discardableResult
    private func retrieve(
        _ sut: SUT
    ) -> SUT.RetrievalResult? {
        
        var retrievalResult: SUT.RetrievalResult?
        let exp = expectation(description: "wait for completion")
        
        sut.retrieve {
            
            retrievalResult = $0
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return retrievalResult
    }
    
    @discardableResult
    private func insert(
        _ sut: SUT,
        _ item: Item,
        validUntil: Date = .init()
    ) -> SUT.InsertionResult? {
        
        var insertionResult: SUT.InsertionResult?
        let exp = expectation(description: "wait for completion")
        
        sut.insert(item, validUntil: validUntil) {
            
            insertionResult = $0
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return insertionResult
    }
    
    @discardableResult
    private func deleteCache(
        _ sut: SUT
    ) -> SUT.DeletionResult? {
        
        var deletionResult: SUT.DeletionResult?
        let exp = expectation(description: "wait for completion")
        
        sut.deleteCache {
            
            deletionResult = $0
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return deletionResult
    }
    
    private func setupEmptyStore() {
        
        removeStoreArtefacts()
    }
    
    private func undoStoreSideEffects() {
        
        removeStoreArtefacts()
    }
    
    private func removeStoreArtefacts() {
        
        makeSUT().clear()
    }
    
    private struct Tag: RawRepresentable {
        
        let rawValue: String
    }
    
    private func anyItem(
        value: String = UUID().uuidString
    ) -> Item {
        
        .init(value: value)
    }
    
    private struct Item: Equatable {
        
        let value: String
    }
}
