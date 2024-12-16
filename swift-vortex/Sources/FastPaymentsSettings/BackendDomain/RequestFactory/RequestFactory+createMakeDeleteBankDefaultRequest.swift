//
//  RequestFactory+createMakeDeleteBankDefaultRequest.swift
//
//
//  Created by Дмитрий Савушкин on 29.09.2024.
//

import Foundation
import RemoteServices
import Tagged

public extension RequestFactory {
    
    static func createMakeDeleteBankDefaultRequest(
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
