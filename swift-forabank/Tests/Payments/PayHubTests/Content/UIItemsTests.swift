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
