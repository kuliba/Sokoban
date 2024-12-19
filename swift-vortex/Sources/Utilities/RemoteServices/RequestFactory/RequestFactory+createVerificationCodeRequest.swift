//
//  RequestFactory+createVerificationCodeRequest.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import Foundation
import Tagged

public extension RequestFactory {
    
    static func createVerificationCodeRequest(
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
}

public extension RequestFactory {
    
    typealias VerificationCode = Tagged<_VerificationCode, String>
    enum _VerificationCode {}
    
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
