//
//  ArrayExtensionsTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 01.06.2023.
//

@testable import ForaBank
import XCTest

final class ArrayExtensionsTests: XCTestCase {
    
    // MARK: - filtered
    
    func test_shouldReturnEmptyOnNilFilteringText() {
        
        let items = [Item]()
        
        let filtered = items.filtered(with: nil, keyPath: \.name)
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_shouldReturnEmptyOnEmptyFilteringText() {
        
        let items = [Item]()
        
        let filtered = items.filtered(with: "", keyPath: \.name)
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_shouldReturnEmptyOnNonEmptyFilteringText() {
        
        let items = [Item]()
        
        let filtered = items.filtered(with: "J", keyPath: \.name)
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_shouldReturnSameOnNilFilteringText() {
        
        let items = Item.samples
        
        let filtered = items.filtered(with: nil, keyPath: \.name)
        
        XCTAssertNoDiff(filtered, items)
    }
    
    func test_shouldReturnSameOnEmptyFilteringText() {
        
        let items = Item.samples
        
        let filtered = items.filtered(with: "", keyPath: \.name)
        
        XCTAssertNoDiff(filtered, items)
    }
    
    func test_shouldReturnFilteredOnNonEmptyFilteringText() {
        
        let items = Item.samples
        
        let filtered = items.filtered(with: "J", keyPath: \.name)
        
        XCTAssertNoDiff(filtered, [
            .init(name: "John"),
            .init(name: "Jane"),
        ])
    }
}

extension ArrayExtensionsTests {
    
    // MARK: - Helpers
    
    private struct Item: Equatable {
        
        let name: String
        
        static let samples: [Item] = [
            .init(name: "John"),
            .init(name: "Jane"),
            .init(name: "Kate")
        ]
    }
}
