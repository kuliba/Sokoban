//
//  RequestFactory+makeSecretRequest2.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2023.
//

import CVVPIN_Services
import Foundation

extension RequestFactory {
    
    static func makeSecretRequest(
        payload: FormSessionKeyService.ProcessPayload
    ) throws -> URLRequest {
        
        let factory = try factory(for: .formSessionKey)
        
        return try factory.makeRequest(
            for: .formSessionKey(.init(
                code: .init(value: payload.code.codeValue),
                data: payload.data
            ))
        )
    }
}
