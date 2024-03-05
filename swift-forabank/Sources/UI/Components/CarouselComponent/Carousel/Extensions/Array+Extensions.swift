//
//  Array+Extensions.swift
//
//
//  Created by Disman Dmitry on 26.02.2024.
//

import Foundation

extension Array where Element: Identifiable {
    
    func first(matching id: Element.ID) -> Element? {
        
        first { $0.id == id }
    }
    
    func firstIndex(matching id: Element.ID) -> Index? {
        
        firstIndex { $0.id == id }
    }
    
}

extension Array where Element: Hashable {

    var uniqueValues: [Element] {
        var allowed = Set(self)
        return compactMap { allowed.remove($0) }
    }
}
