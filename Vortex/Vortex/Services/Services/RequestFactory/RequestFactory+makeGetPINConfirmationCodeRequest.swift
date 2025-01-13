//
//  RequestFactory+makeGetPINConfirmationCodeRequest.swift
//  Vortex
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
            with: [("sessionId", sessionID.sessionIDValue)]
        )
        
        return try factory.makeRequest(
            for: .getPINConfirmationCode(.init(value: sessionID.sessionIDValue))
        )
    }
}
