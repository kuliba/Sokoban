//
//  Array+assignIDsTests.swift
//  
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import XCTest

final class Array_assignIDsTests: XCTestCase {
    
    // MARK: - empty
    
    func test_assignIDs_shouldDeliverEmptyOnEmptyItemsEmptyIDs() {
        
        XCTAssertNoDiff(assignIDs(items: [], ids: []), [])
    }
    
    func test_assignIDs_shouldDeliverEmptyOnEmptyItemsOnOneID() {
        
        XCTAssertNoDiff(assignIDs(items: [], ids: [makeID()]), [])
    }
    
    func test_assignIDs_shouldDeliverEmptyOnEmptyItemsTwoIDs() {
        
        XCTAssertNoDiff(assignIDs(items: [], ids: makeIDs(count: 2)), [])
    }
    
    // MARK: - one
    
    func test_assignIDs_shouldDeliverOneOnOneItemEmptyIDs() {
        
        let item = makeItem()
        
        XCTAssertNoDiff(
            assignIDs(items: [item], ids: []).map(\.element),
            [item])
    }
    
    func test_assignIDs_shouldDeliverOneWithIDOnOneItemOneID() {
        
        let item = makeItem()
        let id = makeID()
        
        XCTAssertNoDiff(
            assignIDs(items: [item], ids: [id]),
            [.init(id: id, element: item)]
        )
    }
    
    func test_assignIDs_shouldDeliverOneOnOneItemTwoIDs() {
        
        let item = makeItem()
        let (id1, id2) = (makeID(), makeID())
        
        XCTAssertNoDiff(
            assignIDs(items: [item], ids: [id1, id2]),
            [.init(id: id1, element: item)])
    }
    
    // MARK: - two
    
    func test_assignIDs_shouldDeliverTwoOnTwoItemsEmptyIDs() {
        
        let (item1, item2) = (makeItem(), makeItem())
        
        XCTAssertNoDiff(
            assignIDs(items: [item1, item2], ids: []).map(\.element),
            [item1, item2]
        )
    }
    
    func test_assignIDs_shouldDeliverTwoWithIDOnTwoItemsOneID() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let id = makeID()
        
        XCTAssertNoDiff(
            assignIDs(items: [item1, item2], ids: [id]).map(\.element),
            [item1, item2]
        )
        XCTAssertNoDiff(
            assignIDs(items: [item1, item2], ids: [id]).map(\.id).first,
            id
        )
    }
    
    func test_assignIDs_shouldDeliverTwoOnTwoItemsTwoIDs() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (id1, id2) = (makeID(), makeID())
        
        XCTAssertNoDiff(assignIDs(items: [item1, item2], ids: [id1, id2]), [
            .init(id: id1, element: item1),
            .init(id: id2, element: item2)
        ])
    }
    
    // MARK: - Helpers
    
    private typealias ID = UUID
    
    private struct Item: Equatable {
        
        let value: String
    }
    
    private func assignIDs(
        items: [Item],
        ids: [ID]
    ) -> [Identified<ID, Item>] {
        
        ids.assignIDs(items, UUID.init)
    }
    
    private func makeItem(
        _ value: String = anyMessage()
    ) -> Item {
        
        return .init(value: value)
    }
    
    private func makeItems(
        count: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) -> [Item] {
        
        let items = (0..<count).map { _ in makeItem() }
        XCTAssertEqual(items.count, count, file: file, line: line)
        return items
    }
    
    private func makeID(
        _ value: UUID = .init()
    ) -> ID {
        
        return value
    }
    
    private func makeIDs(
        count: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) -> [ID] {
        
        let ids = (0..<count).map { _ in makeID() }
        XCTAssertEqual(ids.count, count, file: file, line: line)
        return ids
    }
}
