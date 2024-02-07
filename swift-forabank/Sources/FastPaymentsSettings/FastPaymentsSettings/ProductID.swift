//
//  ProductID.swift
//
//
//  Created by Igor Malyarov on 06.02.2024.
//

public enum ProductID<AccountID, CardID> {
    
    case account(AccountID)
    case card(CardID, accountID: AccountID)
}

extension ProductID: Equatable
where AccountID: Equatable, CardID: Equatable {}

extension ProductID: Hashable
where AccountID: Hashable, CardID: Hashable {}

public extension ProductID {
    
    var accountID: AccountID {
        
        switch self {
        case let .account(accountID),
            let .card(_, accountID):
            return accountID
        }
    }
}
