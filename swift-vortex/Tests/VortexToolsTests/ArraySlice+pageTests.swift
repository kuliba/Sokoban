//
//  ArraySlice+pageTests.swift
//
//
//  Created by Igor Malyarov on 29.02.2024.
//

import XCTest


final class ArraySlice_pageTests: XCTestCase {
    
    // MARK: - startingAt
    
    func test_page_startingAt_shouldReturnEmptyOnMissing() {
        
        let items = items(count: 100)
        
        let page = items.page(startingAt: 111, pageSize: 100)
        
        XCTAssertEqual(page, [])
    }
    
    func test_page_startingAt_shouldReturnEmptyOnLast() {
        
        let items = items(count: 100)
        
        let page = items.page(startingAt: 100, pageSize: 100)
        
        XCTAssertEqual(page, [])
    }
    
    func test_page_startingAt_shouldReturnAllOnPageSizeBiggerThanCount() {
        
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
    
    func test_page_startingAt_shouldReturnPage_02() {
        
        let startingAt = 80
        let pageSize = 10
        let items = items(count: 100)
        
        let page = items.page(startingAt: startingAt, pageSize: pageSize)
        
        XCTAssertEqual(page.map(\.id), (80..<90).map { $0 })
    }
    
    // MARK: - startingAfter
    
    func test_page_startingAfter_shouldReturnEmptyOnMissing() {
        
        let items = items(count: 100)
        
        let page = items.page(startingAfter: 111, pageSize: 100)
        
        XCTAssertEqual(page, [])
    }
    
    func test_page_startingAfter_shouldReturnEmptyOnLast() {
        
        let items = items(count: 100)
        
        let page = items.page(startingAfter: 100, pageSize: 100)
        
        XCTAssertEqual(page, [])
    }
    
    func test_page_startingAfter_shouldReturnAllAfterStartingOnPageSizeBiggerThanCount() {
        
        let count = 100
        let pageSize = 1_000
        let startingAfter = 0
        let items = items(count: count)
        
        let page = items.page(startingAfter: startingAfter, pageSize: pageSize)
        
        XCTAssertEqual(page, .init(items.dropFirst()))
        XCTAssertGreaterThan(pageSize, count)
    }
    
    func test_page_startingAfter_shouldReturnPage_01() {
        
        let startingAfter = 0
        let pageSize = 10
        let items = items(count: 100)
        
        let page = items.page(startingAfter: startingAfter, pageSize: pageSize)
        
        XCTAssertEqual(page.map(\.id), (1..<11).map { $0 })
    }
    
    func test_page_startingAfter_shouldReturnPage_02() {
        
        let startingAfter = 80
        let pageSize = 10
        let items = items(count: 100)
        
        let page = items.page(startingAfter: startingAfter, pageSize: pageSize)
        
        XCTAssertEqual(page.map(\.id), (81..<91).map { $0 })
    }
    
    func test_page_startingAfter_shouldReturnPage_03() {
        
        let startingAfter = 80
        let pageSize = 20
        let count = 100
        let items = items(count: count)
        
        let page = items.page(startingAfter: startingAfter, pageSize: pageSize)
        
        XCTAssertEqual(page.map(\.id), (81..<count).map { $0 })
    }
    
    private struct Item: Equatable, Identifiable {
        
        let id: Int
    }
    
    private func items(count: Int) -> ArraySlice<Item> {
        
        .init((0..<count).map { .init(id: $0) })
    }
}
