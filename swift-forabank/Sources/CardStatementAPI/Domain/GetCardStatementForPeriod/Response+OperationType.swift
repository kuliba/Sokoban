//
//  Response+OperationType.swift
//  
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

extension Response {
    
    enum OperationType: String, Decodable {
        
        case credit = "CREDIT"
        case debit = "DEBIT"
        case open = "OPEN"
        case demandDepositFromAccount = "DV"
    }
}

extension Response.OperationType {
    
    var value: ProductStatementData.OperationType {
        
        switch self {
        case .credit:
            return .credit
        case .debit:
            return .debit
        case .open:
            return .open
        case .demandDepositFromAccount:
            return .demandDepositFromAccount
        }
    }
}
