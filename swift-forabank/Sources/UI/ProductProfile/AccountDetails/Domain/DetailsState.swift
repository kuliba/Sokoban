//
//  DetailsState.swift
//  
//
//  Created by Andryusina Nataly on 07.03.2024.
//

import Foundation

public struct DetailsState: Equatable {
    
    public let items: [ListItem]
    public var event: DetailsEvent?
    
    public init(
        items: [ListItem],
        event: DetailsEvent? = nil
    ) {
        self.items = items
        self.event = event
    }
}
