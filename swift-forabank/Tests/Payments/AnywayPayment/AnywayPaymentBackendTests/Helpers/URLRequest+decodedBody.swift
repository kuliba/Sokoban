//
//  URLRequest+decodedBody.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.12.2023.
//

import XCTest

extension URLRequest {
    
    func decodedBody<T: Decodable>(as type: T.Type) throws -> T {
        
        let data = try XCTUnwrap(httpBody)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
