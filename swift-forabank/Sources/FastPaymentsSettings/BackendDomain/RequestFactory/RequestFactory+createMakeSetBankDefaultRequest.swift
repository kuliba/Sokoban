//
//  RequestFactory+createMakeSetBankDefaultRequest.swift
//
//
//  Created by Igor Malyarov on 29.12.2023.
//

import Foundation
import RemoteServices
import Tagged

public extension RequestFactory {
    
    typealias VerificationCode = Tagged<_VerificationCode, String>
    enum _VerificationCode {}
    
    static func createMakeSetBankDefaultRequest(
        url: URL,
        payload: VerificationCode
    ) throws -> URLRequest {
        
        guard !payload.isEmpty else {
            throw EmptyVerificationCode()
        }
        
        var request = createEmptyRequest(.post, with: url)
        request.httpBody = try payload.httpBody
        return request
    }
    
    struct EmptyVerificationCode: Error {}
}

private extension RequestFactory.VerificationCode {
    
    var httpBody: Data {
        
        get throws {
            
            try JSONSerialization.data(withJSONObject: [
                "verificationCode": rawValue
            ] as [String: String])
        }
    }
}
