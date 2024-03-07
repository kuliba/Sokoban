//
//  DetailsState.swift
//  
//
//  Created by Andryusina Nataly on 07.03.2024.
//

import Foundation

public struct DetailsState: Equatable {
    
    public let items: [ItemForList]
    public var event: DetailsEvent?
    
    public init(
        items: [ItemForList],
        event: DetailsEvent? = nil
    ) {
        self.items = items
        self.event = event
    }
}
