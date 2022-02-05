//
//  OperationType.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import Foundation

enum OperationType: String, Codable {
    
    /// receipt of money to the account
    case credit = "CREDIT"
    
    /// debiting money from an account
    case debit = "DEBIT"
}
