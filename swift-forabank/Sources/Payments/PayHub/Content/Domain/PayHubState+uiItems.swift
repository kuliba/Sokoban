//
//  PayHubState+uiItems.swift
//  
//
//  Created by Igor Malyarov on 17.08.2024.
//

import Foundation

public extension PayHubState {
    
    typealias PayHubUIItem = Identified<UUID, UIItem<Element>>
    
    var uiItems: [PayHubUIItem] {
        
        let templates = PayHubUIItem(.selectable(.templates))
        let exchange = PayHubUIItem(.selectable(.exchange))
        
        var uiItems = [templates, exchange]
        
        switch loadState {
        case let .loaded(loaded):
            uiItems.append(contentsOf: loaded.map { .init(id: $0.id, element: .selectable(.latest($0.element))) })
            
        case let .placeholders(ids):
            uiItems.append(contentsOf: ids.map { .init(id: $0, element: .placeholder($0)) })
        }
        
        return uiItems
    }
}
