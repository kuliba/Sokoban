//
//  RequestFactory+getProductDetailsRequest.swift
//
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation
import Services

public extension RequestFactory {
        
    static func getProductDetailsRequest(
        url: URL,
        payload: ProductDetailsPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}
