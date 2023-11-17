//
//  AuthenticateWithPublicKeyPayload.swift
//  
//
//  Created by Igor Malyarov on 24.10.2023.
//

import Foundation

extension URLRequestFactory.Service {
    
    public struct AuthenticateWithPublicKeyPayload {
        
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
            
            guard !clientPublicKeyRSA.clientPublicKeyRSAValue.isEmpty
            else {
                throw Error.bindPublicKeyWithEventIDEmptyEventID
            }
            
            guard !publicApplicationSessionKey.publicApplicationSessionKeyValue.isEmpty
            else {
                throw Error.bindPublicKeyWithEventIDEmptyEventID
            }
            
            guard !signature.signatureValue.isEmpty
            else {
                throw Error.bindPublicKeyWithEventIDEmptyKey
            }
            
            return try JSONSerialization.data(withJSONObject: [
                "clientPublicKeyRSA": clientPublicKeyRSA.clientPublicKeyRSAValue.base64EncodedString(),
                "publicApplicationSessionKey": publicApplicationSessionKey.publicApplicationSessionKeyValue.base64EncodedString(),
                "signature": signature.signatureValue.base64EncodedString()
            ] as [String: String])
        }
        
        public struct ClientPublicKeyRSA {
            
            public let clientPublicKeyRSAValue: Data
            
            public init(clientPublicKeyRSAValue: Data) {
             
                self.clientPublicKeyRSAValue = clientPublicKeyRSAValue
            }
        }
        
        public struct PublicApplicationSessionKey {
            
            public let publicApplicationSessionKeyValue: Data
            
            public init(publicApplicationSessionKeyValue: Data) {
             
                self.publicApplicationSessionKeyValue = publicApplicationSessionKeyValue
            }
        }
        
        public struct Signature {
            
            public let signatureValue: Data
            
            public init(signatureValue: Data) {
             
                self.signatureValue = signatureValue
            }
        }
    }
}
