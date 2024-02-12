//
//  Product+ext.swift
//
//
//  Created by Igor Malyarov on 06.02.2024.
//

public extension Product {
    
    var accountID: AccountID {
        
        switch id {
        case let .account(accountID): return accountID
        case let .card(_, accountID: accountID): return accountID
        }
    }
}

extension Array where Element == Product {
    
    func product(forAccountID accountID: Element.AccountID) -> Element? {
        
        first { $0.accountID == accountID}
    }
}
