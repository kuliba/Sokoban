//
//  RequestFactory+makeGetPINConfirmationCodeRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.10.2023.
//

import Foundation

extension RequestFactory {
    
    static func makeGetPINConfirmationCodeRequest(
        sessionID: SessionID
    ) throws -> URLRequest {
        
        let factory = try factory(
            for: .getPINConfirmationCode,
            with: [("sessionId", sessionID.value)]
        )
        
        return try factory.makeRequest(
            for: .getPINConfirmationCode(.init(value: sessionID.value))
        )
    }
}
