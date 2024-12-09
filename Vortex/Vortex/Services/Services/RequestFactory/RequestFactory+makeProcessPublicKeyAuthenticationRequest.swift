//
//  RequestFactory+makeProcessPublicKeyAuthenticationRequest.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.10.2023.
//

import CVVPIN_Services
import Foundation
import URLRequestFactory

extension RequestFactory {
    
    static func makeProcessPublicKeyAuthenticationRequest(
        data: Data
    ) throws -> URLRequest {
        
        let factory = try factory(for: .processPublicKeyAuthenticationRequest)
        
        return try factory.makeRequest(
            for: .processPublicKeyAuthenticationRequest(data)
        )
    }
}
