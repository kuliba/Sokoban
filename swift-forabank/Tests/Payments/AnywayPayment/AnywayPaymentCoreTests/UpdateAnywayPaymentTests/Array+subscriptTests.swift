//
//  Array+IdentifiableTests.swift
//
//
//  Created by Igor Malyarov on 05.04.2024.
//

import XCTest

final class Array_IdentifiableTests: XCTestCase {
    
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
    
    func test_subscript_shouldNotChangeOnEmpty() {
        
        var array = [Item]()
        array[id: 2] = makeItem()
        
        XCTAssertNoDiff(array, [])
    }
    
    func test_subscript_shouldNotChangeOnMissing() {
        
        let missing = makeItem(id: 2)
        let initial = [makeItem()]
        var array = initial
        array[id: missing.id] = makeItem()

        XCTAssertNoDiff(array, initial)
    }
    
    func test_subscript_shouldNotChangeOnDifferentIDInNewValue() {
        
        let item = makeItem(id: 1)
        var array = [item]
        array[id: item.id] = makeItem(id: 2)

        XCTAssertNoDiff(array, [item])
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
        value: String = anyMessage()
    ) -> Item {
        
        .init(id: id, value: value)
    }
    
    private struct TestItem<Value: Equatable>: Identifiable, Equatable {
        
        let id: Int
        let value: Value
    }
}
