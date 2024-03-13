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
    public var detailsState: DetailsState

    public init(
        accountDetails: [ListItem],
        cardDetails: [ListItem],
        event: ProductDetailsEvent? = nil,
        showCheckBox: Bool = false,
        title: String = "Реквизиты счета и карты",
        detailsState: DetailsState = .initial
    ) {
        self.accountDetails = accountDetails
        self.cardDetails = cardDetails
        self.event = event
        self.showCheckBox = false
        self.title = title
        self.detailsState = detailsState
    }
    
    public mutating func updateDetailsStateByTap(_ id: DocumentItem.ID) {
        
        switch id {
            
        case .number:
            if detailsState == .needShowNumber { detailsState = .initial }
            else { detailsState = .needShowNumber }
        case .cvv:
            if detailsState == .needShowCvv { detailsState = .initial }
            else { detailsState = .needShowCvv }
        default:
            break
        }
    }
}

public enum DetailsState {
    
    case initial
    case needShowNumber
    case needShowCvv
}
