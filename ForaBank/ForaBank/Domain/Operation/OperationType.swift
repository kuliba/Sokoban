//
//  OperationType.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import Foundation

enum OperationType: String, Codable, Hashable, Unknownable {
    
    /// receipt of money to the account
    case credit = "CREDIT"
    
    /// debiting money from an account
    case debit = "DEBIT"
    
    case open = "OPEN"
    
    // not finance operation transfer account into demand deposit
    case demandDepositFromAccount = "DV"
    
    case unknown
}
