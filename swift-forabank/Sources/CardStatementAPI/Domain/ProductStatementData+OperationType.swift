//
//  ProductStatementData+OperationType.swift
//
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

public extension ProductStatementData {
    
    enum OperationType {
        
        case credit
        
        case debit
        
        case open
        
        case demandDepositFromAccount
    }
}
