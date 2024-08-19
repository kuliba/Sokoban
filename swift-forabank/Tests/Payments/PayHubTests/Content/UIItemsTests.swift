//
//  UIItemsTests.swift
//
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub
import XCTest

final class UIItemsTests: XCTestCase {
    
    // MARK: - Identifiable
    
    func test_id_placeholder() {
        
        let uuid = UUID()
        let uiItem: Item = .placeholder(uuid)
        
        XCTAssertNoDiff(uiItem.id, .placeholder(uuid))
    }
    
    func test_id_exchange() {
        
        let uiItem: Item = .selectable(.exchange)
        
        XCTAssertNoDiff(uiItem.id, .exchange)
    }
    
    func test_id_latest() {
        
        let latest = makeLatest()
        let uiItem: Item = .selectable(.latest(latest))
        
        XCTAssertNoDiff(uiItem.id, .latest(latest.id))
    }
    
    func test_id_templates() {
        
        let uiItem: Item = .selectable(.templates)
        
        XCTAssertNoDiff(uiItem.id, .templates)
    }
    
    // MARK: - uiItems
    
    func test_uiItems_shouldStartWithTemplatesAndExchangeOnNil() {
        
        let uiItems = SUT.none.uiItems
        
        XCTAssertNoDiff(uiItems[0], .selectable(.templates))
        XCTAssertNoDiff(uiItems[1], .selectable(.exchange))
    }
    
    func test_uiItems_shouldEndWithFourUniquePlaceholdersOnNil() {
        
        let tail = SUT.none.uiItems.dropFirst(2).map { $0 }
        
        XCTAssertEqual(tail.count, 4)
        XCTAssertEqual(placeholderUUIDs(tail).count, 4)
        XCTAssertEqual(Set(placeholderUUIDs(tail)).count, 4)
    }
    
    func test_uiItems_shouldStartWithTemplatesAndExchangeOnEmpty() {
        
        let uiItems = SUT.some([]).uiItems
        
        XCTAssertNoDiff(uiItems[0], .selectable(.templates))
        XCTAssertNoDiff(uiItems[1], .selectable(.exchange))
    }
    
    func test_uiItems_shouldEndWithEmptyOnEmpty() {
        
        let tail = SUT.some([]).uiItems.dropFirst(2)
        
        XCTAssertTrue(tail.isEmpty)
    }
    
    func test_uiItems_shouldStartWithTemplatesAndExchangeOnOne() {
        
        let uiItems = SUT.some([makeLatest()]).uiItems
        
        XCTAssertNoDiff(uiItems[0], .selectable(.templates))
        XCTAssertNoDiff(uiItems[1], .selectable(.exchange))
    }
    
    func test_uiItems_shouldEndWithOneLatestOnOne() {
        
        let latest = makeLatest()
        let tail = SUT.some([latest]).uiItems.dropFirst(2)
        
        XCTAssertNoDiff(tail, [.selectable(.latest(latest))])
    }
    
    func test_uiItems_shouldStartWithTemplatesAndExchangeOnTwo() {
        
        let uiItems = SUT.some([makeLatest(), makeLatest()]).uiItems
        
        XCTAssertNoDiff(uiItems[0], .selectable(.templates))
        XCTAssertNoDiff(uiItems[1], .selectable(.exchange))
    }
    
    func test_uiItems_shouldEndWithTwoLatestsOnTwo() {
        
        let (latest1, latest2) = (makeLatest(), makeLatest())
        let tail = SUT.some([latest1, latest2]).uiItems.dropFirst(2)
        
        XCTAssertNoDiff(tail, [
            .selectable(.latest(latest1)),
            .selectable(.latest(latest2)),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = [Latest]?
    private typealias Item = UIItem<Latest>
    
    private struct Latest: Equatable, Identifiable {
        
        let value: String
        
        var id: String { value }
    }
    
    private func makeLatest(
        _ value: String = UUID().uuidString
    ) -> Latest {
        
        return .init(value: value)
    }
    
    private func placeholderUUIDs(
        _ uiItems: [UIItem<Latest>]
    ) -> [UUID] {
        
        uiItems.compactMap {
            
            guard case let .placeholder(uuid) = $0
            else { return nil }
            
            return uuid
        }
    }
}
