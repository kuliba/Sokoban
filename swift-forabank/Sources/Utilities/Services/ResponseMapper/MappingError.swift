//
//  MappingError.swift
//
//
//  Created by Andryusina Nataly on 13.02.2024.
//

import Foundation

public extension ResponseMapper {
    
    enum MappingError: Error, Equatable {
        
        case invalid(statusCode: Int, data: Data)
        case server(statusCode: Int, errorMessage: String)
    }
}
