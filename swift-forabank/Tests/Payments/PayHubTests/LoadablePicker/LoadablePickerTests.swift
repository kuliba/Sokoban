//
//  LoadablePickerTests.swift
//
//
//  Created by Igor Malyarov on 20.08.2024.
//

import PayHub
import XCTest

class LoadablePickerTests: XCTestCase {
    
    // MARK: - Helpers
    
    typealias ID = UUID
    typealias Reducer = LoadablePickerReducer<ID, Element>
    
    func makeItem(
        id: ID = .init(),
        _ element: Element? = nil
    ) -> Reducer.State.Item {
        
        return .element(.init(id: id, element: element ?? makeElement()))
    }
    
    func makeID() -> ID {
        
        return .init()
    }
    
    func makePlaceholderID() -> ID {
        
        return .init()
    }
    
    struct Element: Equatable {
        
        let value: String
    }
    
    func makeElement(
        _ value: String = anyMessage()
    ) -> Element {
        
        return .init(value: value)
    }
}
