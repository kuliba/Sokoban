//
//  BicAccountCheck.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 12.12.2022.
//

import Foundation

struct BicAccountCheck: Decodable, Equatable {
   
    let checkResult: CheckResult
    
    enum CheckResult: String, Codable {
        
        case notValid = "NOT_VALID"
        case individual = "INDIVIDUAL"
        case legal = "LEGAL"
        case entrepreneurs = "ENTREPRENEURS"
        case budget = "BUDGET"
        case other = "OTHER"
        
    }
}
