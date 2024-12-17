//
//  FilterableItemPageTests.swift
//
//
//  Created by Igor Malyarov on 07.12.2024.
//

import ForaTools
import XCTest

final class FilterableItemPageTests: XCTestCase {
    
    func test_page_shouldDeliverEmptyOnEmptyForEmptyQuery() {
        
        XCTAssertNoDiff(page([], for: makeQuery()), [])
    }
    
    func test_page_shouldDeliverEmptyOnEmptyForNonEmptySearch() {
        
        XCTAssertNoDiff(page([], for: makeQuery(search: anyMessage())), [])
    }
    
    func test_page_shouldReturnOneItemForEmptyQuery() {
        
        let items = [makeItem()]
        
        let page = page(items, for: makeQuery(search: ""))
        
        XCTAssertNoDiff(page, items)
    }
    
    func test_page_shouldReturnTwoItemsForEmptyQuery() {
        
        let items = [makeItem(), makeItem()]
        
        let page = page(items, for: makeQuery(search: ""))
        
        XCTAssertNoDiff(page, items)
    }
    
    func test_page_shouldFilterItemsBasedOnSearch() {
        
        let item = makeItem("Foo")
        let query = makeQuery(search: "Foo")
        
        let page = page([item, makeItem()], for: query)
        
        XCTAssertNoDiff(page, [item])
    }
    
    func test_page_shouldReturnPageAfterGivenID() {
        
        let items = (1...5).map { makeItem(id: "\($0)") }
        let query = makeQuery(id: "2", pageSize: 2)
        
        let page = page(items, for: query)
        
        XCTAssertNoDiff(page.map(\.id), ["3","4"])
    }
    
    func test_page_shouldReturnPageOfGivenSizeAfterGivenID() {
        
        let items = (1...10).map { makeItem(id: "\($0)") }
        let query = makeQuery(id: "3", pageSize: 3)
        
        let page = page(items, for: query)
        
        XCTAssertNoDiff(page.map(\.id), ["4", "5", "6"])
    }
    
    func test_page_shouldDeliverEmptyOnMissingID() {
        
        let items = (1...5).map { makeItem(id: "\($0)") }
        let query = makeQuery(id: "99")
        
        let page = page(items, for: query)
        
        XCTAssertNoDiff(page, [])
    }
    
    func test_page_shouldDeliverEmptyOnUnmatchedSearch() {
        
        let items = [makeItem("Foo"), makeItem("Bar")]
        let query = makeQuery(search: "Baz")
        
        let page = page(items, for: query)
        
        XCTAssertNoDiff(page, [])
    }
    
    func test_page_shouldReturnAllRemainingItemsWhenPageSizeExceedsCount() {
        
        let items = (1...5).map { makeItem(id: "\($0)") }
        let query = makeQuery(id: "3", pageSize: 100)
        
        let page = page(items, for: query)
        
        XCTAssertNoDiff(page.map(\.id), ["4", "5"])
    }
    
    func test_page_shouldDeliverEmptyWhenIDIsLastItem() {
        
        let items = (1...3).map { makeItem(id: "\($0)") }
        let query = makeQuery(id: "3", pageSize: 2)
        
        let page = page(items, for: query)
        
        XCTAssertNoDiff(page, [])
    }
    
    func test_page_shouldReturnEmptyForZeroPageSize() {
        
        let items = (1...3).map { makeItem(id: "\($0)") }
        let query = makeQuery(id: "1", pageSize: 0)
        
        let page = page(items, for: query)
        
        XCTAssertNoDiff(page, [])
    }
    
    func test_page_shouldMatchCaseInsensitively() {

        let items = ["FooBar", "foobar", "FOO"].map { makeItem($0) }
        let query = makeQuery(search: "FoO")
        
        let page = page(items, for: query)
        
        XCTAssertNoDiff(page.map(\.title), ["FooBar", "foobar", "FOO"])
    }

    func test_page_shouldReturnSingleItemWhenPageSizeIsOne() {

        let items = (1...5).map { makeItem(id: "\($0)") }
        let query = makeQuery(id: "2", pageSize: 1)
        
        let page = page(items, for: query)
        
        XCTAssertNoDiff(page.map(\.id), ["3"])
    }

    func test_page_shouldFilterMultipleMatchesAndRespectPaging() {

        let items = (1...5).map { makeItem(id: "\($0)", "Bar \($0)") }
        let query = makeQuery(id: "2", pageSize: 2, search: "bar")
        
        let page = page(items, for: query)
        
        XCTAssertNoDiff(page.map(\.id), ["3", "4"])
    }

    func test_page_shouldMatchSubstringsInTitle() {
        
        let items = ["HelloWorld", "WorldHello", "SomethingElse"].map { makeItem($0) }
        let query = makeQuery(search: "ello")
        
        let page = page(items, for: query)
        
        XCTAssertNoDiff(page.map(\.title), ["HelloWorld", "WorldHello"])
    }
    
    // MARK: - Helpers
    
    private struct Item: FilterableItem, Equatable {
        
        let id: String
        let title: String
        
        func matches(_ query: Query) -> Bool {
            
            guard !query.search.isEmpty else { return true }
            
            return title.localizedCaseInsensitiveContains(query.search)
        }
    }
    
    private func makeItem(
        id: String = anyMessage(),
        _ title: String = anyMessage()
    ) -> Item {
        
        return .init(id: id, title: title)
    }
    
    private struct Query: PageQuery {
        
        let id: String?
        let pageSize: Int
        let search: String
    }
    
    private func makeQuery(
        id: String? = nil,
        pageSize: Int = 10,
        search: String = ""
    ) -> Query {
        
        return .init(id: id, pageSize: pageSize, search: search)
    }
    
    private func page(
        _ items: [Item],
        for query: Item.Query
    ) -> [Item] {
        
        items.page(for: query)
    }
}
