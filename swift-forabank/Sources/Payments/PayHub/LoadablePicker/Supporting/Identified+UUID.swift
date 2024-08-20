//
//  Identified+UUID.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

import Foundation

public extension Identified where ID == UUID {
    
    init(_ element: Element) {
        
        self.init(id: .init(), element: element)
    }
}
