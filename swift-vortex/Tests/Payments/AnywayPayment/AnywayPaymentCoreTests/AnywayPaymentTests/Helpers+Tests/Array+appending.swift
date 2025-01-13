//
//  Array+appending.swift
//  
//
//  Created by Igor Malyarov on 05.04.2024.
//

extension Array {
    
    func appending(_ element: Element) -> Self {
        
        var copy = self
        copy.append(element)
        return copy
    }
    
    func appending(contentsOf elements: [Element]) -> Self {
        
        var copy = self
        copy.append(contentsOf: elements)
        return copy
    }
}
