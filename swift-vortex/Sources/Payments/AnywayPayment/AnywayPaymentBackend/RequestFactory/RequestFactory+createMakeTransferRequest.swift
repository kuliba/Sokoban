//
//  RequestFactory+createMakeTransferRequest.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import Foundation
import RemoteServices
import Tagged

public extension RequestFactory {
    
    static func createMakeTransferRequest(
        url: URL,
        payload: VerificationCode
    ) throws -> URLRequest {
        
        try createVerificationCodeRequest(url: url, payload: payload)
    }
}
