//
//  Array+IdentifiableTests.swift
//
//
//  Created by Igor Malyarov on 05.03.2024.
//

import XCTest

final class Array_IdentifiableTests: XCTestCase {
    
    func test_subscript_shouldReturnNilOnEmpty() {
        
        let array = [Item]()
        
        XCTAssertNil(array[id: UUID()])
    }
    
    func test_subscript_shouldReturnNilOnMissing() {
        
        let missing = Item()
        let array = [Item()]
        
        XCTAssertNil(array[id: missing.id])
    }
    
    func test_subscript_shouldReturnItemOnMatchingID() {
        
        let matching = Item()
        let array = [matching]
        
        XCTAssertNoDiff(array[id: matching.id], matching)
    }
    
    func test_subscript_shouldReturnItemOnMatchingID_first() {
        
        let matching = Item()
        let array = [matching, .init()]
        
        XCTAssertNoDiff(array[id: matching.id], matching)
    }
    
    func test_subscript_shouldReturnItemOnMatchingID_last() {
        
        let matching = Item()
        let array = [.init(), matching]
        
        XCTAssertNoDiff(array[id: matching.id], matching)
    }
    
    func test_subscript_setterShouldNotChangeEmpty() {
        
        let item = Item()
        var array = [Item]()
        
        array[id: item.id]?.value = "abc"
        
        XCTAssertNoDiff(array, [])
    }
    
    func test_subscript_setterShouldNotChangeEmpty_nil() {
        
        let item = Item()
        var array = [Item]()
        
        array[id: item.id] = nil
        
        XCTAssertNoDiff(array, [])
    }
    
    func test_subscript_shouldChangeOnExisting_one() {
        
        let item = Item()
        var array = [item]
        
        array[id: item.id]?.value = "abc"
        
        XCTAssertNoDiff(array[id: item.id]?.id, item.id)
        XCTAssertNoDiff(array[id: item.id]?.value, "abc")
    }
    
    func test_subscript_shouldChangeOnExisting_first() {
        
        let item = Item()
        var array = [item, .init()]
        
        array[id: item.id]?.value = "abc"
        
        XCTAssertNoDiff(array[id: item.id]?.id, item.id)
        XCTAssertNoDiff(array[id: item.id]?.value, "abc")
    }
    
    func test_subscript_shouldChangeOnExisting_last() {
        
        let item = Item()
        var array = [.init(), item]
        
        array[id: item.id]?.value = "abc"
        
        XCTAssertNoDiff(array[id: item.id]?.id, item.id)
        XCTAssertNoDiff(array[id: item.id]?.value, "abc")
    }
    
    func test_subscript_shouldReplaceExisting_one() {
        
        let item = Item()
        var array = [item]
        
        array[id: item.id] = .init(id: item.id, value: "abc")
        
        XCTAssertNoDiff(array[id: item.id]?.id, item.id)
        XCTAssertNoDiff(array[id: item.id]?.value, "abc")
    }
    
    func test_subscript_shouldReplaceExisting_first() {
        
        let item = Item()
        var array = [item, .init()]
        
        array[id: item.id] = .init(id: item.id, value: "abc")

        XCTAssertNoDiff(array[id: item.id]?.id, item.id)
        XCTAssertNoDiff(array[id: item.id]?.value, "abc")
    }
    
    func test_subscript_shouldReplaceExisting_last() {
        
        let item = Item()
        var array = [.init(), item]
        
        array[id: item.id] = .init(id: item.id, value: "abc")

        XCTAssertNoDiff(array[id: item.id]?.id, item.id)
        XCTAssertNoDiff(array[id: item.id]?.value, "abc")
    }
    
    func test_subscript_shouldRemoveExistingOnNil_one() {
        
        let item = Item()
        var array = [item]
        
        array[id: item.id] = nil
        
        XCTAssertNoDiff(array, [])
    }
    
    func test_subscript_shouldRemoveExistingOnNil_first() {
        
        let item = Item()
        let other = Item()
        var array = [item, other]
        
        array[id: item.id] = nil
        
        XCTAssertNoDiff(array, [other])
    }
    
    func test_subscript_shouldRemoveExistingOnNil_last() {
        
        let item = Item()
        let other = Item()
        var array = [other, item]
        
        array[id: item.id] = nil
        
        XCTAssertNoDiff(array, [other])
    }
    
    func test_subscript_shouldAppendNonNil_empty() {
        
        let new = Item()
        var array = [Item]()
        
        array[id: new.id] = new
        
        XCTAssertNoDiff(array, [new])
    }
    
    func test_subscript_shouldAppendNonNil_one() {
        
        let new = Item()
        let other = Item()
        var array = [other]
        
        array[id: new.id] = new
        
        XCTAssertNoDiff(array, [other, new])
    }
    
    func test_subscript_shouldAppendNonNil_two() {
        
        let new = Item()
        let first = Item()
        let second = Item()
        var array = [first, second]
        
        array[id: new.id] = new
        
        XCTAssertNoDiff(array, [first, second, new])
    }
    
    // MARK: - Helpers
    
    struct Item: Identifiable, Equatable {
        
        var id = UUID()
        var value = ""
    }
}
