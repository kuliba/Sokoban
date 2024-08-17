//
//  PayHubState+uiItemsTests.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

import PayHub
import XCTest

final class PayHubState_uiItemsTests: XCTestCase {
    
    func test_uiItems_shouldStartWithTemplatesAndExchangeOnPlaceholders() {
        
        let uiItems = makePlaceholdersSUT().uiItems
        
        XCTAssertNoDiff(uiItems[0].element, .selectable(.templates))
        XCTAssertNoDiff(uiItems[1].element, .selectable(.exchange))
    }
    
    func test_uiItems_shouldEndWithPlaceholdersOnPlaceholders() {
        
        let ids = makeIDs(count: 9)
        let tail = makePlaceholdersSUT(ids: ids).uiItems.dropFirst(2)
        
        XCTAssertEqual(tail.count, 9)
    }
    
    func test_uiItems_shouldStartWithTemplatesAndExchangeOnEmpty() {
        
        let uiItems = makeLoadedSUT([]).uiItems
        
        XCTAssertNoDiff(uiItems[0].element, .selectable(.templates))
        XCTAssertNoDiff(uiItems[1].element, .selectable(.exchange))
    }
    
    func test_uiItems_shouldEndWithEmptyOnEmpty() {
        
        let tail = makeLoadedSUT([]).uiItems.dropFirst(2)
        
        XCTAssertTrue(tail.isEmpty)
    }
    
    func test_uiItems_shouldStartWithTemplatesAndExchangeOnOne() {
        
        let uiItems = makeLoadedSUT([.init(makeElement())]).uiItems
        
        XCTAssertNoDiff(uiItems[0].element, .selectable(.templates))
        XCTAssertNoDiff(uiItems[1].element, .selectable(.exchange))
    }
    
    func test_uiItems_shouldEndWithOneElementOnOne() {
        
        let latest = makeElement()
        let tail = makeLoadedSUT([.init(latest)]).uiItems.dropFirst(2)

        XCTAssertNoDiff(tail.map(\.element), [.selectable(.latest(latest))])
    }
    
    func test_uiItems_shouldStartWithTemplatesAndExchangeOnTwo() {
        
        let uiItems = makeLoadedSUT([.init(makeElement()), .init(makeElement())]).uiItems
        
        XCTAssertNoDiff(uiItems[0].element, .selectable(.templates))
        XCTAssertNoDiff(uiItems[1].element, .selectable(.exchange))
    }
    
    func test_uiItems_shouldEndWithTwoElementsOnTwo() {
        
        let (latest1, latest2) = (makeElement(), makeElement())
        let tail = makeLoadedSUT([.init(latest1), .init(latest2)]).uiItems.dropFirst(2)
        
        XCTAssertNoDiff(tail.map(\.element), [
            .selectable(.latest(latest1)),
            .selectable(.latest(latest2)),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PayHubState<Element>
    private typealias Item = UIItem<Element>
    
    private func makeLoadedSUT(
        _ loaded: [Identified<UUID, Element>],
        selected: SUT.Item? = nil
    ) -> SUT {
        
        return .init(
            loadState: .loaded(loaded),
            selected: selected
        )
    }
    
    private func makePlaceholdersSUT(
        ids: [UUID]? = nil,
        selected: SUT.Item? = nil
    ) -> SUT {
        
        return .init(
            loadState: .placeholders(ids ?? makeIDs(count: 4)),
            selected: selected
        )
    }
    
    private func makeIDs(
        count: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) -> [UUID] {
        
        let ids = (0..<count).map { _ in UUID() }
        XCTAssertEqual(ids.count, count, file: file, line: line)
        return ids
    }
    
    private struct Element: Equatable, Identifiable {
        
        let value: String
        
        var id: String { value }
    }
    
    private func makeElement(
        _ value: String = UUID().uuidString
    ) -> Element {
        
        return .init(value: value)
    }
}
