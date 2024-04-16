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
    
    static func createMakeSetBankDefaultRequest(
        url: URL,
        payload: VerificationCode
    ) throws -> URLRequest {
        
        try createVerificationCodeRequest(url: url, payload: payload)
    }
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
