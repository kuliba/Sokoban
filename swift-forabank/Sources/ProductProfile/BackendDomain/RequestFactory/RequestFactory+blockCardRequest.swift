//
//  RequestFactory+blockCardRequest.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import Foundation
import Tagged
import Services

public extension RequestFactory {
        
    static func blockCardRequest(
        url: URL,
        payload: Payloads.CardPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}
