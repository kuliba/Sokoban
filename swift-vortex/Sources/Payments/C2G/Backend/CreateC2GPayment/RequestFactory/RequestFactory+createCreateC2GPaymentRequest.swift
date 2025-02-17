//
//  RequestFactory+createCreateC2GPaymentRequest.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Foundation
import RemoteServices

public extension RequestFactory {
    
    static func createCreateC2GPaymentRequest(
        url: URL,
        payload: CreateC2GPaymentPayload
    ) throws -> URLRequest {
        
        guard !payload.uin.isEmpty else { throw EmptyUIN() }
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        
        return request
    }
}

private extension RequestFactory.CreateC2GPaymentPayload {
    
    var httpBody: Data {
        
        get throws {
            
            var dictionary: [String: Any] = ["UIN": uin]
            
            if let accountID {
                dictionary["accountId"] = accountID
            } else if let cardID {
                dictionary["cardId"] = cardID
            } else {
                throw MissingPaymentIdentifiers()
            }
            
            return try JSONSerialization.data(withJSONObject: dictionary, options: [])
        }
    }
}

public extension RequestFactory.CreateC2GPaymentPayload {
    
    struct MissingPaymentIdentifiers: Error {}
}
