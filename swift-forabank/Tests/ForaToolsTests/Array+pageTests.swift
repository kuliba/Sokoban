//
//  Array+pageTests.swift
//
//
//  Created by Igor Malyarov on 29.02.2024.
//

import XCTest


final class Array_pageTests: XCTestCase {
    
    func test_page_shouldReturnEmptyOnMissing() {
        
        let items = items(count: 100)
        
        let page = items.page(startingAt: 111, pageSize: 100)
        
        XCTAssertEqual(page, [])
    }
    
    func test_page_shouldReturnEmptyOnLast() {
        
        let items = items(count: 100)
        
        let page = items.page(startingAt: 100, pageSize: 100)
        
        XCTAssertEqual(page, [])
    }
    
    func test_page_shouldReturnAllOnPageSizeBiggerThanCount() {
        
        let count = 100
        let pageSize = 1_000
        let items = items(count: count)
        
        let page = items.page(startingAt: 0, pageSize: pageSize)
        
        XCTAssertEqual(page, items)
        XCTAssertGreaterThan(pageSize, count)
    }
    
    func test_page_shouldReturnPage_01() {
        
        let startingAt = 0
        let pageSize = 10
        let items = items(count: 100)
        
        let page = items.page(startingAt: startingAt, pageSize: pageSize)
        
        XCTAssertEqual(page.map(\.id), (0..<10).map { $0 })
    }
    
    func test_page_shouldReturnPage_02() {
        
        let startingAt = 80
        let pageSize = 10
        let items = items(count: 100)
        
        let page = items.page(startingAt: startingAt, pageSize: pageSize)
        
        XCTAssertEqual(page.map(\.id), (80..<90).map { $0 })
    }
    
    private struct Item: Equatable, Identifiable {
        
        let id: Int
    }
    
    private func items(count: Int) -> [Item] {
        
        (0..<count).map { .init(id: $0) }
    }
}
