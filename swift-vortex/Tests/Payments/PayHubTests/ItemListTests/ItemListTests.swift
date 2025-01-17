//
//  ItemListTests.swift
//  
//
//  Created by Igor Malyarov on 17.01.2025.
//

import PayHub
import XCTest

class ItemListTests: XCTestCase {
    
    typealias ID = Int
    typealias Domain = ItemListDomain<ID, Entity>
    typealias State = Domain.State
    typealias Item = State.Item
    typealias Element = Stateful<Entity, LoadState>
    
    func makeItem(
        id: ID? = nil,
        entity: Entity? = nil,
        state: LoadState = .loading
    ) -> Item {
        
        return .element(.init(
            id: id ?? makePlaceholderID(),
            element: .init(
                entity: entity ?? makeEntity(),
                state: state
            )
        ))
    }
    
    func makeElement(
        entity: Entity? = nil,
        state: LoadState = .loading
    ) -> Element {
        
        return .init(entity: entity ?? makeEntity(), state: state)
    }
    
    func makeIdentified(
        id: ID,
        element: Element
    ) -> Identified<ID, Element> {
        
        return .init(id: id, element: element)
    }
    
    func makePlaceholderID() -> ID {
        
        return .random(in: 1...100)
    }
    
    struct Entity: Equatable, Identifiable {
        
        let value: String
        
        var id: String { value }
    }
    
    func makeEntity(
        _ value: String = anyMessage()
    ) -> Entity {
        
        return .init(value: value)
    }
}
