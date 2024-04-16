//
//  ListItem.swift
//  
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation

public enum ListItem: Hashable {
    
    case single(ProductDetail)
    case multiple([ProductDetail])
    
    var currentValues: [ProductDetail] {
        
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
                
            case .cvv:
                return nil
                
            default:
                return $0.title + ": " + $0.value.copyValue
            }
        }.joined(separator: "\n")
    }
}
