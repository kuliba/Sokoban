//
//  RequestFactory+createGetSVCardLimitRequest.swift
//
//
//  Created by Andryusina Nataly on 18.06.2024.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetSVCardLimitRequest(
        url: URL,
        payload: GetSVCardLimitPayload
    ) throws -> URLRequest {
                
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}

private extension GetSVCardLimitPayload {
    
    var httpBody: Data {
        
        get throws {
            return try JSONSerialization.data(
                withJSONObject: ["cardId": cardId] as [String: Int]
            )
        }
    }
}

