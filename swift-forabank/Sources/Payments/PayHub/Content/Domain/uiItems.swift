//
//  uiItems.swift
//
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

public extension Optional
where Wrapped: RandomAccessCollection {
    
    var uiItems: [UIItem<Wrapped.Element>] {
        
        typealias Item = UIItem<Wrapped.Element>
        
        var uiItems = [Item.selectable(.templates), .selectable(.exchange)]
        
        switch self {
        case .none:
            let uuids = (0..<4).map { _ in UUID() }
            uiItems.append(contentsOf: uuids.map(Item.placeholder))
            
        case let .some(latests):
            uiItems.append(contentsOf: latests.map { Item.selectable(.latest($0)) })
        }
        
        return uiItems
    }
}
