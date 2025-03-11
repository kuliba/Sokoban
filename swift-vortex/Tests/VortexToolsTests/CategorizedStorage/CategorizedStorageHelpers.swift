//
//  CategorizedStorageHelpers.swift
//
//
//  Created by Igor Malyarov on 11.03.2025.
//

import VortexTools
import XCTest

class CategorizedStorageHelpers: XCTestCase {
    
    typealias Storage = CategorizedStorage<String, Item>
    
    func makeEmptyStorage() -> Storage {
        
        return .init(entries: [:])
    }
    
    func makeSingleItemStorage() -> Storage {
        
        let entry = Storage.Entry(
            items: [.init(category: "fruits", name: "Apple")],
            serial: "serial-1"
        )
        
        return .init(entries: ["fruits": entry])
    }
    
    func makeTwoItemStorage() -> Storage {
        
        let entry = CategorizedStorage<String, Item>.Entry(
            items: [
                .init(category: "fruits", name: "Apple"),
                .init(category: "fruits", name: "Banana")
            ],
            serial: "serial-2"
        )
        
        return .init(entries: ["fruits": entry])
    }
    
    func makeItem(
        category: String = anyMessage(),
        name: String = anyMessage()
    ) -> Item {
        
        return .init(category: category, name: name)
    }
    
    struct Item: Categorized, Equatable {
        
        let category: String
        let name: String
    }
    
    struct TransformedItem: Categorized, Equatable {
        
        let category: String
        let nameLength: Int
    }
}
