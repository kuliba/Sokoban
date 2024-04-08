//
//  Array+subscriptTests.swift
//
//
//  Created by Igor Malyarov on 05.04.2024.
//

import ForaTools
import XCTest

final class Array_subscriptTests: XCTestCase {
    
    func test_subscript_shouldDeliverNilOnEmpty() {
        
        let array = [Item]()
        
        XCTAssertNil(array[id: 1])
    }
    
    func test_subscript_shouldDeliverNilOnMissing() {
        
        let array = [makeItem(id: 2)]
        
        XCTAssertNil(array[id: 1])
    }
    
    func test_subscript_shouldDeliverElementOnPresent() {
        
        let item = makeItem(id: 2)
        let array = [item]

        XCTAssertNoDiff(array[id: 2], item)
    }
    
    func test_subscript_shouldAppendToEmpty() {
        
        let item = makeItem()
        var array = [Item]()
        array[id: 2] = item
        
        XCTAssertNoDiff(array, [item])
    }
    
    func test_subscript_shouldAppendOnMissing() {
        
        let missing = makeItem(id: 2)
        let new = makeItem()
        let initial = [makeItem()]
        var array = initial
        array[id: missing.id] = new

        XCTAssertNoDiff(array, initial + [new])
    }
    
    func test_subscript_shouldAppendToOneOnDifferentIDInNewValue() {
        
        let item = makeItem(id: 2)
        let different = makeItem(id: 1)
        var array = [item]
        array[id: item.id] = different

        XCTAssertNoDiff(array, [item, different])
    }
    
    func test_subscript_shouldAppendToTwoOnDifferentIDInNewValue() {
        
        let item = makeItem(id: 2)
        let other = makeItem(id: 4)
        let different = makeItem(id: 1)
        var array = [item, other]
        array[id: item.id] = different

        XCTAssertNoDiff(array, [item, other, different])
    }
    
    func test_subscript_shouldChangeOnPresentOnNewValueWithSameID() {
        
        let id = generateRandom11DigitNumber()
        let item = makeItem(id: id)
        var array = [item]
        array[id: item.id] = makeItem(id: id, value: "abc")

        XCTAssertNoDiff(array, [makeItem(id: id, value: "abc")])
    }
    
    func test_subscript_shouldRemoveOnNil() {
        
        let item = makeItem()
        var array = [item]
        array[id: item.id] = nil

        XCTAssertNoDiff(array, [])
    }
    
    // MARK: - Helpers
    
    private typealias Item = TestItem<String>
    
    private func makeItem(
        id: Int = generateRandom11DigitNumber(),
        value: String = UUID().uuidString
    ) -> Item {
        
        .init(id: id, value: value)
    }
    
    private struct TestItem<Value: Equatable>: Identifiable, Equatable {
        
        let id: Int
        let value: Value
    }
}
