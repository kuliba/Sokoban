//
//  ProcessPublicKeyAuthenticationRequestPayload.swift
//  
//
//  Created by Igor Malyarov on 12.10.2023.
//

import Foundation

extension URLRequestFactory.Service {
    
    public struct ProcessPublicKeyAuthenticationRequestPayload {
        
        public let clientPublicKeyRSA: ClientPublicKeyRSA
        public let publicApplicationSessionKey: PublicApplicationSessionKey
        public let signature: Signature
        
        public init(
            clientPublicKeyRSA: ClientPublicKeyRSA,
            publicApplicationSessionKey: PublicApplicationSessionKey,
            signature: Signature
        ) {
            self.clientPublicKeyRSA = clientPublicKeyRSA
            self.publicApplicationSessionKey = publicApplicationSessionKey
            self.signature = signature
        }
        
        func json() throws -> Data {
            
            guard !clientPublicKeyRSA.rawValue.isEmpty
            else {
                throw Error.processPublicKeyAuthenticationRequestEmptyClientPublicKeyRSA
            }
            
            guard !publicApplicationSessionKey.rawValue.isEmpty
            else {
                throw Error.processPublicKeyAuthenticationRequestEmptyPublicApplicationSessionKey
            }
            
            guard !signature.rawValue.isEmpty
            else {
                throw Error.processPublicKeyAuthenticationRequestEmptySignature
            }
            
            return try JSONSerialization.data(withJSONObject: [
                "clientPublicKeyRSA": clientPublicKeyRSA.rawValue.base64EncodedString(),
                "publicApplicationSessionKey": publicApplicationSessionKey.rawValue.base64EncodedString(),
                "signature": signature.rawValue.base64EncodedString()
            ] as [String: String])
        }
    }
}

extension URLRequestFactory.Service.ProcessPublicKeyAuthenticationRequestPayload {
    
    public struct ClientPublicKeyRSA {
        
        public let rawValue: Data
        
        public init(rawValue: Data) {
            
            self.rawValue = rawValue
        }
    }
    public struct PublicApplicationSessionKey {
        
        public let rawValue: Data
        
        public init(rawValue: Data) {
            
            self.rawValue = rawValue
        }
    }
    public struct Signature {
        
        public let rawValue: Data
        
        public init(rawValue: Data) {
            
            self.rawValue = rawValue
        }
    }
}

