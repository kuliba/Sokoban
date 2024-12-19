//
//  ProductDetailsState+ext.swift
//
//
//  Created by Andryusina Nataly on 08.03.2024.
//

import Foundation

public extension ProductDetailsState {
    
    static let initialState = ProductDetailsState(
        accountDetails: .accountItems,
        cardDetails: .cardItems
    )
}
