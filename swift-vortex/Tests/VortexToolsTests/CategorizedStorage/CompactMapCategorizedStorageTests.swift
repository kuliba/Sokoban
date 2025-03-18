//
//  CompactMapCategorizedStorageTests.swift
//  
//
//  Created by Igor Malyarov on 11.03.2025.
//

import VortexTools
import XCTest

final class CompactMapCategorizedStorageTests: CategorizedStorageHelpers {

    func test_compactMap_shouldFilterOutNilValues() {
        
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
                    .init(category: "drinks", name: "Whiskey"),
                    .init(category: "drinks", name: "Juice")
                ],
                serial: "serial-drinks"
            )
        ])
        
        let compactMapped = storage.compactMap { item in
            
            item.name.count > 5 ? item : nil
        }
        
        XCTAssertNoDiff(compactMapped.items(for: "fruits")?.count, 1)
        XCTAssertNoDiff(compactMapped.items(for: "fruits")?.first?.name, "Banana")
        
        XCTAssertNoDiff(compactMapped.items(for: "drinks")?.count, 1)
        XCTAssertNoDiff(compactMapped.items(for: "drinks")?.first?.name, "Whiskey")
        
        XCTAssertNoDiff(compactMapped.serial(for: "fruits"), "serial-fruits")
        XCTAssertNoDiff(compactMapped.serial(for: "drinks"), "serial-drinks")
    }
    
    func test_compactMap_shouldRemoveEmptyCategories() {
        
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
        
        let compactMapped = storage.compactMap { item in
            
            item.category == "fruits" ? nil : item // Removes all "fruits"
        }
        
        XCTAssertNil(compactMapped.items(for: "fruits")) // Entire category is removed
        XCTAssertNoDiff(compactMapped.items(for: "drinks")?.count, 1)
        XCTAssertNoDiff(compactMapped.serial(for: "drinks"), "serial-drinks")
    }
}
