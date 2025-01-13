//
//  RequestFactory+makeChangePINRequest.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.10.2023.
//

import Foundation

extension RequestFactory {
    
    static func makeChangePINRequest(
        sessionID: SessionID,
        data: Data
    ) throws -> URLRequest {
        
        let factory = try factory(for: .changePIN)
        
        return try factory.makeRequest(
            for: .changePIN(.init(
                sessionID: .init(value: sessionID.sessionIDValue),
                data: data
            ))
        )
    }
}
