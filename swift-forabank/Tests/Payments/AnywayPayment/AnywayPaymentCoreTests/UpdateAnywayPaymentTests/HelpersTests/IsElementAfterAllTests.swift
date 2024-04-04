//
//  IsElementAfterAllTests.swift
//
//
//  Created by Igor Malyarov on 04.04.2024.
//

import XCTest

final class IsElementAfterAllTests: XCTestCase {
    
    func test_isElementAfterAll_shouldReturnFalseOnEmptyArrayAndGroup() {
        
        let missing = Item(id: 2)
        
        XCTAssertFalse([].isElementAfterAll(missing, inGroup: []))
    }
    
    func test_isElementAfterAll_shouldReturnFalseOnEmptyArray() {
        
        let missing = Item(id: 2)
        
        XCTAssertFalse([].isElementAfterAll(missing, inGroup: [.init(id: 1)]))
    }
    
    func test_isElementAfterAll_shouldReturnFalseForMissingElement() {
        
        let missing = Item(id: 2)
        let array = [1, 3, 4].map { Item(id: $0) }
        let group = [3, 4].map { Item(id: $0) }
        
        XCTAssertFalse(array.isElementAfterAll(missing, inGroup: group))
        XCTAssertFalse(array.map(\.id).contains(missing.id))
    }
    
    func test_isElementAfterAll_shouldReturnTrueOnLast() {
        
        let last = Item(id: 3)
        let array = [1, 2, 3].map { Item(id: $0) }
        let group = [1, 2].map { Item(id: $0) }
        
        XCTAssert(array.isElementAfterAll(last, inGroup: group))
    }
    
    // MARK: - Helpers
    
    private struct Item: Identifiable {
        
        let id: Int
        let value: String = UUID().uuidString
    }
}
