//
//  InMemoryStoreTests.swift
//
//
//  Created by Igor Malyarov on 12.10.2024.
//

import EphemeralStores
import XCTest

final class InMemoryStoreTests: XCTestCase {
    
    func test_retrieve_shouldDeliverNilOnEmpty() async {
        
        let sut = makeSUT()
        
        let retrieved = await sut.retrieve()
        
        XCTAssertNil(retrieved)
    }
    
    func test_retrieve_shouldHaveNoSideEffectOnEmpty() async {
        
        let sut = makeSUT()
        
        let retrievedFirst = await sut.retrieve()
        let retrievedLast = await sut.retrieve()
        
        XCTAssertNil(retrievedFirst)
        XCTAssertNil(retrievedLast)
    }
    
    func test_retrieve_shouldDeliverValueOnNonEmpty() async {
        
        let value = makeValue()
        let sut = makeSUT(value: value)
        
        let retrieved = await sut.retrieve()
        
        XCTAssertNoDiff(retrieved, value)
    }
    
    func test_retrieve_shouldHaveNoSideEffectOnNonEmpty() async {
        
        let value = makeValue()
        let sut = makeSUT(value: value)
        
        let retrievedFirst = await sut.retrieve()
        let retrievedLast = await sut.retrieve()
        
        XCTAssertNoDiff(retrievedFirst, value)
        XCTAssertNoDiff(retrievedLast, value)
    }
    
    func test_insert_shouldInsertValue() async {
        
        let value = makeValue()
        let sut = makeSUT()
        
        await sut.insert(value)
        let retrieved = await sut.retrieve()
        
        XCTAssertNoDiff(retrieved, value)
    }
    
    func test_insert_shouldOverridePreviouslyInsertedValue() async {
        
        let first = makeValue()
        let last = makeValue()
        let sut = makeSUT()
        
        await sut.insert(first)
        await sut.insert(last)
        let retrieved = await sut.retrieve()
        
        XCTAssertNoDiff(retrieved, last)
    }
    
    func test_delete_shouldHaveNoSideEffectsOnEmpty() async {
        
        let sut = makeSUT()
        
        await sut.delete()
        let deleted = await sut.retrieve()
        
        XCTAssertNil(deleted)
    }
    
    func test_delete_shouldDeleteValue() async {
        
        let sut = makeSUT()
        
        await sut.insert(makeValue())
        await sut.delete()
        let deletedItem = await sut.retrieve()
        
        XCTAssertNil(deletedItem)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = InMemoryStore<Value>
    
    private func makeSUT(
        value: Value? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(value: value)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private struct Value: Equatable {
        
        let value: String
    }
    
    private func makeValue(
        _ value: String = anyMessage()
    ) -> Value {
        
        return .init(value: value)
    }
}
