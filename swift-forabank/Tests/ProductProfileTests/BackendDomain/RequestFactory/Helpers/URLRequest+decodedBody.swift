//
//  URLRequest+decodedBody.swift
//  
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import XCTest

extension URLRequest {
    
    func decodedBody<T: Decodable>(as type: T.Type) throws -> T {
        
        let data = try XCTUnwrap(httpBody)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
