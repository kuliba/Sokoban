//
//  RequestFactory+makeGetProcessingSessionCode.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.10.2023.
//

import Foundation

extension RequestFactory {
    
    static func makeGetProcessingSessionCode(
    ) throws -> URLRequest {
        
        let factory = try factory(for: .getProcessingSessionCode)
        
        return try factory.makeRequest(for: .getProcessingSessionCode)
    }
}
