//
//  DiffArrayTests.swift
//
//
//  Created by Igor Malyarov on 14.01.2025.
//

import VortexTools
import XCTest

final class DiffArrayTests: XCTestCase {
    
    // MARK: - Empty Array Comparisons
    
    func test_diff_shouldReturnEmpty_whenBothArraysAreEmpty() {
        
        let first: [Item] = []
        let second: [Item] = []
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [:])
    }
    
    func test_diff_shouldReturnAllElements_whenFirstArrayHasItemsAndSecondIsEmpty() {
        
        let first = [
            Item(id: 1, value: "A"),
            Item(id: 2, value: "B")
        ]
        let second: [Item] = []
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [1: "A", 2: "B"])
    }
    
    func test_diff_shouldReturnEmpty_whenFirstArrayIsEmptyAndSecondHasItems() {
        
        let first: [Item] = []
        let second = [
            Item(id: 1, value: "A"),
            Item(id: 2, value: "B")
        ]
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [:])
    }
    
    // MARK: - Single Item Comparisons
    
    func test_diff_shouldReturnEmpty_whenBothArraysHaveIdenticalSingleItem() {
        
        let first = [Item(id: 1, value: "A")]
        let second = [Item(id: 1, value: "A")]
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [:])
    }
    
    func test_diff_shouldReturnChangedValue_whenSingleItemDiffers() {
        
        let first = [Item(id: 1, value: "A")]
        let second = [Item(id: 1, value: "B")]
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [1: "A"])
    }
    
    func test_diff_shouldReturnItem_whenFirstArrayHasItemMissingInSecondArray() {
        
        let first = [Item(id: 1, value: "A")]
        let second: [Item] = []
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [1: "A"])
    }
    
    func test_diff_shouldReturnEmpty_whenFirstArrayHasOneItemAndSecondHasTwoIncludingMatch() {
        
        let first = [Item(id: 1, value: "A")]
        let second = [
            Item(id: 1, value: "A"),
            Item(id: 2, value: "B")
        ]
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [:])
    }
    
    // MARK: - Two Item Comparisons
    
    func test_diff_shouldReturnEmpty_whenBothArraysHaveIdenticalTwoItems() {
        
        let first = [
            Item(id: 1, value: "A"),
            Item(id: 2, value: "B")
        ]
        let second = [
            Item(id: 1, value: "A"),
            Item(id: 2, value: "B")
        ]
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [:])
    }
    
    func test_diff_shouldReturnChangedValue_whenOneItemDiffersInTwoItemArray() {
        
        let first = [
            Item(id: 1, value: "A"),
            Item(id: 2, value: "B")
        ]
        let second = [
            Item(id: 1, value: "X"),
            Item(id: 2, value: "B")
        ]
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [1: "A"])
    }
    
    func test_diff_shouldReturnAllChangedValues_whenBothItemsDiffer() {
        
        let first = [
            Item(id: 1, value: "A"),
            Item(id: 2, value: "B")
        ]
        let second = [
            Item(id: 1, value: "X"),
            Item(id: 2, value: "Y")
        ]
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [1: "A", 2: "B"])
    }
    
    func test_diff_shouldReturnRemovedItem_whenSecondArrayIsMissingAnItem() {
        
        let first = [
            Item(id: 1, value: "A"),
            Item(id: 2, value: "B")
        ]
        let second = [Item(id: 1, value: "A")]
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [2: "B"])
    }
    
    // MARK: - Edge Cases
    
    func test_diff_shouldReturnEmpty_whenArraysContainSameItemsInDifferentOrder() {
        
        let first = [
            Item(id: 2, value: "B"),
            Item(id: 1, value: "A")
        ]
        let second = [
            Item(id: 1, value: "A"),
            Item(id: 2, value: "B")
        ]
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [:])
    }
    
    func test_diff_shouldHandleDuplicateIDsInArray() {
        
        let first = [
            Item(id: 1, value: "A"),
            Item(id: 1, value: "B")
        ]
        let second = [Item(id: 1, value: "A")]
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [1: "B"])
    }
    
    func test_diff_shouldHandleMixedChangesAndRemovals() {
        
        let first = [
            Item(id: 1, value: "A"),
            Item(id: 2, value: "B"),
            Item(id: 3, value: "C")
        ]
        let second = [
            Item(id: 1, value: "X"),
            Item(id: 3, value: "C")
        ]
        
        let result = first.diff(second, keyPath: \.value)
        
        XCTAssertEqual(result, [1: "A", 2: "B"])
    }
    
    // MARK: - Helpers
    
    private struct Item: Identifiable, Equatable {
        
        let id: Int
        let value: String
    }
}
