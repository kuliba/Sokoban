//
//  RequestFactory+createGetBankDefaultRequest.swift
//
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation
import RemoteServices
import Tagged

public extension RequestFactory {
    
    static func createGetBankDefaultRequest(
        url: URL,
        payload: PhoneNumber
    ) throws -> URLRequest {
        
        guard !payload.isEmpty else {
            throw EmptyPhoneNumber()
        }
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
    
    struct EmptyPhoneNumber: Error {}
}

private extension PhoneNumber {
    
    var httpBody: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "phoneNumber": rawValue
            ] as [String: String])
        }
    }
}
