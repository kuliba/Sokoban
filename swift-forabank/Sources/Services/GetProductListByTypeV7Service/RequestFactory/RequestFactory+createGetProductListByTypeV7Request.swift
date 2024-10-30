//
//  RequestFactory+createGetProductListByTypeV7Request.swift
//
//
//  Created by Andryusina Nataly on 28.10.2024.
//

import ForaTools
import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetProductListByTypeV7Request(
        parameters: [String: String],
        url: URL
    ) throws -> URLRequest {
        
        let url = try url.appendingQueryItems(parameters: parameters)
        return createEmptyRequest(.get, with: url)
    }
}
