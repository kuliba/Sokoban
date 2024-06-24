//
//  Dictionary+IdentifiableTests.swift
//
//
//  Created by Igor Malyarov on 23.06.2024.
//

import ForaTools
import XCTest

final class Dictionary_IdentifiableTests: XCTestCase {
    
    func test_init_shouldCreateEmptyOnEmptyArray() {
        
        let array = [Item]()
        
        XCTAssertNoDiff(Dictionary(array: array), [:])
    }
    
    func test_init_shouldCreateNonEmptyOnNonEmptyArrayWithUniqueIDs() {
        
        let array = [makeItem(), makeItem(), makeItem()]
        
        let dict = Dictionary(array: array)
        
        XCTAssertEqual(dict.count, array.count)
        
        for item in array {
            
            XCTAssertNoDiff(dict[item.id], item)
        }
    }
    
    func test_init_shouldWithDuplicateIdsUsingLast() {
        
        let id = UUID().uuidString
        let array = [
            makeItem(id: id, value: "Alice"),
            makeItem(id: id, value: "Bob"),
            makeItem()
        ]
        
        let dict = Dictionary(array: array, useLast: true)
        
        XCTAssertEqual(dict.count, 2)
        
        XCTAssertNoDiff(dict[id]?.value, "Bob")
    }
    
    func test_init_shouldWithDuplicateIdsUsingFirst() {
        
        let id = UUID().uuidString
        let array = [
            makeItem(id: id, value: "Alice"),
            makeItem(id: id, value: "Bob"),
            makeItem()
        ]
        
        let dict = Dictionary(array: array, useLast: false)
        
        XCTAssertEqual(dict.count, 2)
        
        XCTAssertNoDiff(dict[id]?.value, "Alice")
    }
    
    // MARK: - Helpers
    
    private func makeItem(
        id: String = UUID().uuidString,
        value: String = UUID().uuidString
    ) -> Item {
        
        return .init(id: id, value: value)
    }
}

private struct Item: Equatable, Identifiable {
    
    let id: String
    let value: String
}
