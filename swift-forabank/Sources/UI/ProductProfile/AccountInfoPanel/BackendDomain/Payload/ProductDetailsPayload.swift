//
//  ProductDetailsPayload.swift
//
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation
import Tagged

public struct ProductDetailsPayload {
    
    let accountId: AccountId?
    let cardId: CardId?
    let depositId: DepositId?
    
    public init(
        accountId: AccountId?,
        cardId: CardId?,
        depositId: DepositId?
    ) {
        self.accountId = accountId
        self.cardId = cardId
        self.depositId = depositId
    }
}

public extension ProductDetailsPayload {
    
    typealias AccountId = Tagged<_AccountId, Int>
    enum _AccountId {}
    
    typealias CardId = Tagged<_CardId, Int>
    enum _CardId {}
    
    typealias DepositId = Tagged<_DepositId, Int>
    enum _DepositId {}
}

extension ProductDetailsPayload {
    
    var httpBody: Data {
        
        get throws {
            
            var parameters: [String: Int] = [:]
            
            if let accountId {
                
                parameters["accountId"] = accountId.rawValue
            }
            
            if let cardId {
                
                parameters["cardId"] = cardId.rawValue
            }

            if let depositId {
                
                parameters["depositId"] = depositId.rawValue
            }
            return try JSONSerialization.data(withJSONObject: parameters as [String: Int])
        }
    }
}
