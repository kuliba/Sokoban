//
//  RequestFactory+unblockCardRequest.swift
//
//
//  Created by Andryusina Nataly on 12.02.2024.
//

import Foundation
import Tagged
import RemoteServices

public extension RequestFactory {
        
    static func unblockCardRequest(
        url: URL,
        payload: Payloads.CardPayload
    ) throws -> URLRequest {
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
}
