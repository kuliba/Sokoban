//
//  RequestFactory+createGetUINDataRequest.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createGetUINDataRequest(
        url: URL,
        payload: GetUINDataPayload
    ) throws -> URLRequest {
        
        guard !payload.uin.isEmpty else { throw EmptyUIN() }
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        
        return request
    }
    
    struct EmptyUIN: Error {}
}

private extension RequestFactory.GetUINDataPayload {
    
    var httpBody: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "UIN": uin
            ] as [String: String])
        }
    }
}
