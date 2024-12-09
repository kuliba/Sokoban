//
//  URLRequest+decodedBody.swift
//  
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import XCTest

extension URLRequest {
    
    func decodedBody<T: Decodable>(as type: T.Type) throws -> T {
        
        let data = try XCTUnwrap(httpBody)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
