//
//  Response+OperationEnvironment.swift
//  
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

extension Response {
    
    enum OperationEnvironment: String, Decodable {
        
        case inside = "INSIDE"
        case outside = "OUTSIDE"
    }
}

extension Response.OperationEnvironment {
    
    var value: ProductStatementData.OperationEnvironment {
        
        switch self {
        case .inside:
            return .inside
        case .outside:
            return .outside
        }
    }
}
