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
    var showCheckBox: Bool
    public var title: String

    public init(
        accountDetails: [ListItem],
        cardDetails: [ListItem],
        event: ProductDetailsEvent? = nil,
        showCheckBox: Bool = false,
        title: String = "Реквизиты счета и карты"
    ) {
        self.accountDetails = accountDetails
        self.cardDetails = cardDetails
        self.event = event
        self.showCheckBox = false
        self.title = title
    }
}
