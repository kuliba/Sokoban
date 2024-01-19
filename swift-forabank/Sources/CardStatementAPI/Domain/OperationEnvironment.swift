//
//  OperationEnvironment.swift
//  
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

extension GetCardStatementForPeriodResponse {
    
    enum OperationEnvironment: String, Codable {
        
        case inside = "INSIDE"
        case outside = "OUTSIDE"
        case unknown
    }
}
