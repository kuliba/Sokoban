//
//  RequestFactory+makeProcessPublicKeyAuthenticationRequest.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.10.2023.
//

import Foundation

extension RequestFactory {
    
    static func makeProcessPublicKeyAuthenticationRequest(
        clientPublicKeyRSA: ClientPublicKeyRSA,
        publicApplicationSessionKey: PublicApplicationSessionKey,
        signature: Signature
    ) throws -> URLRequest {
        
        let factory = try factory(for: .processPublicKeyAuthenticationRequest)
        
        return try factory.makeRequest(
            for: .processPublicKeyAuthenticationRequest(
                .init(
                    clientPublicKeyRSA: .init(rawValue: clientPublicKeyRSA.rawValue),
                    publicApplicationSessionKey: .init(rawValue: publicApplicationSessionKey.rawValue),
                    signature: .init(rawValue: signature.rawValue)
                )
            )
        )
    }
    
    struct ClientPublicKeyRSA {
        
        let rawValue: Data
    }
    struct PublicApplicationSessionKey {
        
        let rawValue: Data
    }
    struct Signature {
        
        let rawValue: Data
    }
}
