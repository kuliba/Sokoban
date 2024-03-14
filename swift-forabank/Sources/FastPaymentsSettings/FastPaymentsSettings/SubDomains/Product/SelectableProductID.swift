//
//  SelectableProductID.swift
//
//
//  Created by Igor Malyarov on 06.02.2024.
//

public enum SelectableProductID: Equatable {
    
    case account(Product.AccountID)
    case card(Product.CardID)
}

public extension Product.ID {
    
    var selectableProductID: SelectableProductID {
        
        switch self {
        case let .account(accountID): return .account(accountID)
        case let .card(cardID, _): return .card(cardID)
        }
    }
}

public extension Product {
    
    var selectableProductID: SelectableProductID {
        
        id.selectableProductID
    }
}
