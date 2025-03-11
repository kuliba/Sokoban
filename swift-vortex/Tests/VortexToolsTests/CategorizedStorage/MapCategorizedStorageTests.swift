//
//  MapCategorizedStorageTests.swift
//  
//
//  Created by Igor Malyarov on 11.03.2025.
//

import VortexTools
import XCTest

final class MapCategorizedStorageTests: CategorizedStorageHelpers {

    func test_map_shouldTransformItems() {
        
        let storage = Storage(entries: [
            "fruits": .init(
                items: [
                    .init(category: "fruits", name: "Apple"),
                    .init(category: "fruits", name: "Banana")
                ],
                serial: "serial-fruits"
            ),
            "drinks": .init(
                items: [
                    .init(category: "drinks", name: "Water")
                ],
                serial: "serial-drinks"
            )
        ])
        
        let mapped = storage.map { item in
            
            TransformedItem(category: item.category, nameLength: item.name.count)
        }
        
        XCTAssertNoDiff(mapped.items(for: "fruits")?.count, 2)
        XCTAssertNoDiff(mapped.items(for: "fruits")?.first?.nameLength, 5) // "Apple"
        XCTAssertNoDiff(mapped.items(for: "fruits")?.last?.nameLength, 6)  // "Banana"
        
        XCTAssertNoDiff(mapped.items(for: "drinks")?.count, 1)
        XCTAssertNoDiff(mapped.items(for: "drinks")?.first?.nameLength, 5) // "Water"
        
        XCTAssertNoDiff(mapped.serial(for: "fruits"), "serial-fruits")
        XCTAssertNoDiff(mapped.serial(for: "drinks"), "serial-drinks")
    }
}
