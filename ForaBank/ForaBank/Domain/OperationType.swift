//
//  OperationType.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import Foundation

enum OperationType: String, Codable {
    
    /// + 100
    case credit = "CREDIT"
    
    /// - 100
    case debit = "DEBIT"
}
