//
//  Identified.swift
//
//
//  Created by Igor Malyarov on 17.08.2024.
//

/// A structure that associates an element with a unique identifier.
public struct Identified<ID, Element>: Identifiable
where ID: Hashable {
    
    public let id: ID
    public let element: Element
    
    public init(
        id: ID,
        element: Element
    ) {
        self.id = id
        self.element = element
    }
}

extension Identified: Equatable where Element: Equatable {}
