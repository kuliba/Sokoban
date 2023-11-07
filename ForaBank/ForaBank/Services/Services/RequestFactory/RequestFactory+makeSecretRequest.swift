//
//  RequestFactory+createSecretRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.08.2023.
//

import CvvPin
import Foundation

extension RequestFactory {
    
    static func makeSecretRequest(
        from secretRequest: FormSessionKeyDomain.Request
    ) throws -> URLRequest {
        
        let factory = try factory(for: .formSessionKey)
        
        return try factory.makeRequest(
            for: .formSessionKey(.init(
                code: .init(value: secretRequest.code),
                data: secretRequest.data
            ))
        )
    }
}
