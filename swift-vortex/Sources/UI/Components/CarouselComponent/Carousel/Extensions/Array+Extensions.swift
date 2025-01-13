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

extension Array where Element: Equatable {

    var uniqueValues: [Element] {
        
        var allowed = [Element]()
        self.forEach {
            if !allowed.contains($0) { allowed.append($0) }
        }
        return allowed
    }
}
