//
//  ProductDetailsState.swift
//  
//
//  Created by Andryusina Nataly on 07.03.2024.
//

import Foundation

public struct ProductDetailsState: Equatable {
    
    public let accountDetails: [ListItem]
    public let cardDetails: [ListItem]
    public var event: ProductDetailsEvent?
    
    public init(
        accountDetails: [ListItem],
        cardDetails: [ListItem],
        event: ProductDetailsEvent? = nil
    ) {
        self.accountDetails = accountDetails
        self.cardDetails = cardDetails
        self.event = event
    }
}
