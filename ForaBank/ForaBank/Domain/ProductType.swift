//
//  ProductType.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import Foundation

enum ProductType: String, Codable {
    
    case deposit = "DEPOSIT"
    case card = "CARD"
    case account = "ACCOUNT"
    case loan = "LOAN"
}
