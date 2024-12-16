//
//  RequestFactory+createGetSVCardLimitsRequest.swift
//
//
//  Created by Andryusina Nataly on 18.06.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetSVCardLimitsRequest(
        url: URL,
        payload: GetSVCardLimitsPayload
    ) throws -> URLRequest {
                
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

private extension GetSVCardLimitsPayload {
    
    var httpBody: Data {
        
        get throws {
            return try JSONSerialization.data(
                withJSONObject: ["cardId": cardId] as [String: Int]
            )
        }
    }
}

