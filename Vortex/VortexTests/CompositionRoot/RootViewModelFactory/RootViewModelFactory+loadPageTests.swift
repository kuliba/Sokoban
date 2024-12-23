//
//  RootViewModelFactory+loadPageTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 07.12.2024.
//

@testable import Vortex
import VortexTools
import XCTest

final class RootViewModelFactory_loadPageTests: RootViewModelFactoryLocalLoadTests {
    
    func test_init_shouldNotCallLoggerForMissingValue() {
        
        let (_, logger) = makeSUT(loadStub: nil)
        
        XCTAssertEqual(logger.callCount, 0)
    }
    
    func test_init_shouldNotCallLoggerForEmpty() {
        
        let (_, logger) = makeSUT(loadStub: [])
        
        XCTAssertEqual(logger.callCount, 0)
    }
    
    func test_init_shouldNotCallLoggerForOne() {
        
        let (_, logger) = makeSUT(loadStub: [makeValue()])
        
        XCTAssertEqual(logger.callCount, 0)
    }
    
    func test_init_shouldNotCallLoggerForTwo() {
        
        let (_, logger) = makeSUT(loadStub: [makeValue(), makeValue()])
        
        XCTAssertEqual(logger.callCount, 0)
    }
    
    func test_shouldDeliverNilForMissingValue() {
        
        let (sut, _) = makeSUT(loadStub: nil)
        
        let page = page(sut, for: makeQuery())
        
        XCTAssertNil(page)
    }
    
    func test_shouldDeliverMessageForMissingValue() {
        
        let (sut, logger) = makeSUT(loadStub: nil)
        
        page(sut, for: makeQuery())
        
        XCTAssertNoDiff(logger.events, [
            message("No values for type Array<Value>.")
        ])
    }
    
    func test_shouldDeliverEmptyForEmpty() {
        
        let (sut, _) = makeSUT(loadStub: nil)
        
        let page = page(sut, for: makeQuery())
        
        XCTAssertNil(page)
    }
    
    func test_shouldDeliverMessageForEmpty() {
        
        let (sut, logger) = makeSUT(loadStub: nil)
        
        page(sut, for: makeQuery())
        
        XCTAssertNoDiff(logger.events, [
            message("No values for type Array<Value>.")
        ])
    }
    
    func test_shouldDeliverOneForOne() {
        
        let items = [makeValue()]
        let (sut, _) = makeSUT(loadStub: items)
        
        let page = page(sut, for: makeQuery())
        
        XCTAssertNoDiff(page, items)
    }
    
    func test_shouldDeliverMessageForOne() {
        
        let (sut, logger) = makeSUT(loadStub: [makeValue()])
        
        page(sut, for: makeQuery())
        
        XCTAssertNoDiff(logger.events, [
            message("Loaded 1 item(s) of type Array<Value>."),
            message("Page with 1 item(s) of 1 total.")
        ])
    }
    
    func test_shouldDeliverTwoForTwo() {
        
        let items = [makeValue(), makeValue()]
        let (sut, _) = makeSUT(loadStub: items)
        
        let page = page(sut, for: makeQuery())
        
        XCTAssertNoDiff(page, items)
    }
    
    func test_shouldDeliverMessageForTwo() {
        
        let (sut, logger) = makeSUT(loadStub: [makeValue(), makeValue()])
        
        page(sut, for: makeQuery())
        
        XCTAssertNoDiff(logger.events, [
            message("Loaded 2 item(s) of type Array<Value>."),
            message("Page with 2 item(s) of 2 total.")
        ])
    }
    
    func test_shouldDeliverFilteredPageForSearch_page() {
        
        let items = ["Foo", "Bar", "Baz", "Qux"].map { makeValue($0) }
        let (sut, _) = makeSUT(loadStub: items)
        
        let page = page(sut, for: makeQuery(search: "Ba"))
        
        XCTAssertNoDiff(page?.map(\.value), ["Bar", "Baz"])
    }

    func test_shouldDeliverFilteredPageForSearch_logs() {
        
        let items = ["Foo", "Bar", "Baz", "Qux"].map { makeValue($0) }
        let (sut, logger) = makeSUT(loadStub: items)
        
        page(sut, for: makeQuery(search: "Ba"))
        
        XCTAssertNoDiff(logger.events, [
            message("Loaded 4 item(s) of type Array<Value>."),
            message("Page with 2 item(s) of 4 total.")
        ])
    }

    func test_shouldDeliverEmptyForUnmatchedSearchWithNonEmptyStub_page() {
        
        let items = ["Foo", "Bar"].map { makeValue($0) }
        let (sut, _) = makeSUT(loadStub: items)
        
        let page = page(sut, for: makeQuery(search: "Zzz"))
        
        XCTAssertNoDiff(page, [])
    }

    func test_shouldDeliverEmptyForUnmatchedSearchWithNonEmptyStub_logs() {
        
        let items = ["Foo", "Bar"].map { makeValue($0) }
        let (sut, logger) = makeSUT(loadStub: items)
        
        page(sut, for: makeQuery(search: "Zzz"))
        
        XCTAssertNoDiff(logger.events, [
            message("Loaded 2 item(s) of type Array<Value>."),
            message("Page with 0 item(s) of 2 total.")
        ])
    }

    func test_shouldDeliverFilteredPageAfterGivenIDForSearch_page() {
        
        let items = ["Foo", "Bar", "Baz", "Qux"].map { makeValue($0) }
        let (sut, _) = makeSUT(loadStub: items)
        
        let page = page(sut, for: makeQuery(id: "Bar", pageSize: 1, search: "Ba"))
        
        XCTAssertNoDiff(page?.map(\.value), ["Baz"])
    }

    func test_shouldDeliverFilteredPageAfterGivenIDForSearch_logs() {
        
        let items = ["Foo", "Bar", "Baz", "Qux"].map { makeValue($0) }
        let (sut, logger) = makeSUT(loadStub: items)
        
        page(sut, for: makeQuery(id: "Bar", pageSize: 1, search: "Ba"))
        
        XCTAssertNoDiff(logger.events, [
            message("Loaded 4 item(s) of type Array<Value>."),
            message("Page with 1 item(s) of 4 total.")
        ])
    }    // MARK: - Helpers
    
    @discardableResult
    private func page(
        _ sut: SUT,
        for query: Query
    ) -> [Value]? {
        
        sut.loadPage(of: [Value].self, for: query)
    }
    
    struct Query: PageQuery {
        
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
}

extension RootViewModelFactoryLocalLoadTests.Value: FilterableItem {
    
    typealias Query = RootViewModelFactory_loadPageTests.Query
    
    var id: String { value }
    
    func matches(_ query: Query) -> Bool {
        
        guard !query.search.isEmpty else { return true }
        
        return value.localizedCaseInsensitiveContains(query.search)
    }
}
