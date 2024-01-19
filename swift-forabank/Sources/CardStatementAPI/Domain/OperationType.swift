//
//  OperationType.swift
//  
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

extension GetCardStatementForPeriodResponse {
    
    enum OperationType: String, Codable {
        
        /// receipt of money to the account
        case credit = "CREDIT"
        
        /// debiting money from an account
        case debit = "DEBIT"
        
        case open = "OPEN"
        
        // not finance operation transfer account into demand deposit
        case demandDepositFromAccount = "DV"
        
        case unknown
    }
}
