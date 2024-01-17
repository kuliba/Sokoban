//
//  DecodeProductStatmentData.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 17.01.2024.
//

import Foundation

struct DecodeProductStatmentData: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: [ProductStatementData]?
}
