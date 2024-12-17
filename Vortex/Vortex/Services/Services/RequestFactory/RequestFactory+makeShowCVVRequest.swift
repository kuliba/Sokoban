//
//  RequestFactory+makeShowCVVRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.10.2023.
//

import Foundation

extension RequestFactory {
    
    static func makeShowCVVRequest(
        sessionID: SessionID,
        data: Data
    ) throws -> URLRequest {
        
        let factory = try factory(for: .showCVV)
        
        return try factory.makeRequest(
            for: .showCVV(.init(
                sessionID: .init(value: sessionID.sessionIDValue),
                data: data
            ))
        )
    }
}
