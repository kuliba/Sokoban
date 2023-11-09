//
//  RequestFactory+makeBindPublicKeyWithEventIDRequest2.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2023.
//

import CVVPIN_Services
import Foundation
import URLRequestFactory

extension RequestFactory {
    
    static func makeBindPublicKeyWithEventIDRequest(
        payload: BindPublicKeyWithEventIDService.ProcessPayload
    ) throws -> URLRequest {
        
        let factory = try factory(for: .bindPublicKeyWithEventID)
        
        return try factory.makeRequest(
            for: .bindPublicKeyWithEventID(.init(
                eventID: .init(value: payload.eventID.eventIDValue),
                key: .init(value: payload.data)
            ))
        )
    }
}

