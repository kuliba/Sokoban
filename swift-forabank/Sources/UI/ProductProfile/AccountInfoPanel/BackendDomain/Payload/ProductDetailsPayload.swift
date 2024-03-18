//
//  ProductDetailsPayload.swift
//
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation
import Tagged

public typealias ProductDetailsPayload = ProductId

public enum ProductId {
    
    case accountId(AccountId)
    case cardId(CardId)
    case depositId(DepositId)
}

public extension ProductId {
    
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
            
            switch self {
            case let .accountId(accountId):
                parameters["accountId"] = accountId.rawValue
                
            case let .cardId(cardId):
                parameters["cardId"] = cardId.rawValue
                
            case let .depositId(depositId):
                parameters["depositId"] = depositId.rawValue
            }
            
            return try JSONSerialization.data(withJSONObject: parameters as [String: Int])
        }
    }
}
