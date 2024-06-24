//
//  Array+uniqueValuesTests.swift
//
//
//  Created by Igor Malyarov on 04.06.2024.
//

import ForaTools
import XCTest

final class Array_uniqueValuesTests: XCTestCase {
    
    // MARK: - Hashable
    
    func test_uniqueValuesHashable_withEmptyArray_shouldReturnEmpty() {
        
        let array: [Int] = []
        
        let unique = array.uniqueValues()
        
        XCTAssertTrue(unique.isEmpty)
    }
    
    func test_uniqueValuesHashable_withSingleElement_shouldReturnSameArray() {
        
        let array = [1]
        
        let unique = array.uniqueValues()
        
        XCTAssertNoDiff(unique, [1])
    }
    
    func test_uniqueValuesHashable_withDuplicates_shouldReturnUniqueValues() {
        
        let array = [1, 2, 2, 3, 1]
        
        let unique = array.uniqueValues(useLast: false)
        
        XCTAssertNoDiff(unique, [1, 2, 3])
    }
    
    func test_uniqueValuesHashable_withDuplicates_keepLast() {
        
        let array = [1, 2, 2, 3, 1]
        
        let unique = array.uniqueValues(useLast: true)
        
        XCTAssertNoDiff(unique, [2, 3, 1])
    }
    
    func test_uniqueValuesHashable_withDuplicates_keepFirst() {
        
        let array = [1, 2, 2, 3, 1]
        
        let unique = array.uniqueValues(useLast: false)
        
        XCTAssertNoDiff(unique, [1, 2, 3])
    }
    
    // MARK: - Identifiable
    
    func test_uniqueValuesIdentifiable_withEmptyArray_shouldReturnEmpty() {
        
        let array: [TestIdentifiable] = []
        
        let unique = array.uniqueValues()
        
        XCTAssertTrue(unique.isEmpty)
    }
    
    func test_uniqueValuesIdentifiable_withSingleElement_shouldReturnSameArray() {
        
        let item = TestIdentifiable(id: "1", value: 1)
        let array = [item]
        
        let unique = array.uniqueValues()
        
        XCTAssertNoDiff(unique, [item])
    }
    
    func test_uniqueValuesIdentifiable_withDuplicates_shouldReturnUniqueValues() {
        
        let item1 = TestIdentifiable(id: "1", value: 1)
        let item2 = TestIdentifiable(id: "2", value: 2)
        let item3 = TestIdentifiable(id: "3", value: 3)
        let array = [item1, item2, item2, item3, item1]
        
        let unique = array.uniqueValues()
        
        XCTAssertNoDiff(unique, [item2, item3, item1])
    }
    
    func test_uniqueValuesIdentifiable_withDuplicates_keepLast() {
        let item1 = TestIdentifiable(id: "1", value: 1)
        let item2 = TestIdentifiable(id: "2", value: 2)
        let item3 = TestIdentifiable(id: "3", value: 3)
        let array = [item1, item2, item2, item3, item1]
        
        let unique = array.uniqueValues(useLast: true)
        
        XCTAssertNoDiff(unique, [item2, item3, item1])
    }
    
    func test_uniqueValuesIdentifiable_withDuplicates_keepFirst() {
        
        let item1 = TestIdentifiable(id: "1", value: 1)
        let item2 = TestIdentifiable(id: "2", value: 2)
        let item3 = TestIdentifiable(id: "3", value: 3)
        let array = [item1, item2, item2, item3, item1]
        
        let unique = array.uniqueValues(useLast: false)
        
        XCTAssertNoDiff(unique, [item1, item2, item3])
    }
}

private struct TestIdentifiable: Identifiable, Equatable {
    
    let id: String
    let value: Int
}
