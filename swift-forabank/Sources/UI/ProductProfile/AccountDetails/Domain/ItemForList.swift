//
//  ItemForList.swift
//  
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation

enum ItemForList: Hashable {
    
    func hash(into hasher: inout Hasher) {
        
        switch self {
        case let .single(item):
            hasher.combine(item)
        case let .multiple(items):
            hasher.combine(items)
        }
    }
    
    case single(Item)
    case multiple([Item])
    
    var currentValues: [Item] {
        
        switch self {
        case let .single(item):
            
            return [item]
            
        case let .multiple(items):
            
            return items
        }
    }
    
    var currentValueString: String {
        
        self.currentValues.compactMap {
            
            switch $0.id {
                
            case .cvv, .cvvMasked:
                return nil
                
            default:
                return $0.title + ": " + $0.valueForCopy
            }
        }.joined(separator: "\n")
    }
}
