//
//  ItemForList.swift
//  
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation

public enum ItemForList: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        
        switch self {
        case let .single(item):
            hasher.combine(item)
        case let .multiple(items):
            hasher.combine(items)
        }
    }
    
    case single(Detail)
    case multiple([Detail])
    
    var currentValues: [Detail] {
        
        switch self {
        case let .single(detail):
            
            return [detail]
            
        case let .multiple(details):
            
            return details
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
