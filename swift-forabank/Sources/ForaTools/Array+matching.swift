//
//  Array+matching.swift
//
//
//  Created by Andryusina Nataly on 14.06.2024.
//

import Foundation

public extension Array where Element: Identifiable {
    
    func first(matching id: Element.ID) -> Element? {
        
        first { $0.id == id }
    }
    
    func firstIndex(matching id: Element.ID) -> Index? {
        
        firstIndex { $0.id == id }
    }
    
    func firstIndex(matching element: Element) -> Index? {
        
        firstIndex { $0.id == element.id }
    }
}
