//
//  RequestFactory+createChangeSVCardLimitRequest.swift
//
//
//  Created by Andryusina Nataly on 14.06.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createChangeSVCardLimitRequest(
        url: URL,
        payload: ChangeSVCardLimitPayload
    ) throws -> URLRequest {
                
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

private extension ChangeSVCardLimitPayload {
    
    var httpBody: Data {
        
        get throws {
            
            let limit: [String: Any] = [
                "name": limit.name,
                "value": limit.value
            ]

            let parameters: [String: Any] = [
                "cardId": cardId,
                "limit": limit
            ]
                        
            return try JSONSerialization.data(
                withJSONObject: parameters as [String: Any]
            )
        }
    }
}

