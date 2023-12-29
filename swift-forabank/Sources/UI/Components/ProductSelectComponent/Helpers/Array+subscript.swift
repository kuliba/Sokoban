//
//  Array+subscript.swift
//  
//
//  Created by Igor Malyarov on 19.12.2023.
//

extension Array where Element: Identifiable {
    
    subscript(id: Element.ID) -> Element? {
     
        first(where: { $0.id == id })
    }
}
