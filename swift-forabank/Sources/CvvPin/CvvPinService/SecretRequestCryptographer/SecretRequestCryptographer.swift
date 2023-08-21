//
//  SecretRequestCryptographer.swift
//  
//
//  Created by Igor Malyarov on 20.07.2023.
//

import CryptoKit
import Foundation

public final class SecretRequestCryptographer: SecretRequestCrypto {
    
    public typealias MakeECDHKeys = () throws -> (saS: SaS, paS: PaS)
    public typealias Encrypt = (Data) throws -> Data
    
    private let makeECDHKeys: MakeECDHKeys
    private let encrypt: Encrypt
    
    public init(
        makeECDHKeys: @escaping MakeECDHKeys,
        encrypt: @escaping Encrypt
    ) {
        self.makeECDHKeys = makeECDHKeys
        self.encrypt = encrypt
    }
    
    public func makeSecretRequest(
        sessionCode: CryptoSessionCode,
        completion: @escaping Completion
    ) {
        completion(.init {
            
            let paS = try makeECDHKeys().paS
            let wrapped = try Self.wrap(paS, andEncrypt: encrypt)
            
            return .init(
                code: .init(value: sessionCode.value),
                data: wrapped.base64EncodedString()
            )
        })
    }
    
    public static func wrap(
        _ paS: PaS,
        andEncrypt encrypt: Encrypt
    ) throws -> Data {
        
        try wrap(paS.rawRepresentation, andEncrypt: encrypt)
    }

    #warning("move this wrapper out to the caller, this is not crypto responsibility")
    private static func wrap(
        _ pasRawRepresentation: Data,
        andEncrypt encrypt: Encrypt
    ) throws -> Data {
        
        let pasKey = "publicApplicationSessionKey"
        let base64 = pasRawRepresentation.base64EncodedString()
        let json: [String: Any] = [pasKey: base64]
        let data = try JSONSerialization.data(withJSONObject: json)
        let encrypted = try encrypt(data)
        
        return encrypted
    }
    
    public struct SaS {
        
        private let key: P384.KeyAgreement.PrivateKey
        
        init(key: P384.KeyAgreement.PrivateKey) {
         
            self.key = key
        }
        
        public var publicKey: P384.KeyAgreement.PublicKey {
            
            key.publicKey
        }
        
        public func sharedSecretFromKeyAgreement(
            with paS: PaS
        ) throws -> SharedSecret {
            
            try key.sharedSecretFromKeyAgreement(with: paS.key)
        }
    }
    
    public struct PaS {
        
        internal let key: P384.KeyAgreement.PublicKey
        
        public init(key: P384.KeyAgreement.PublicKey) {
            
            self.key = key
        }
        
        public var rawRepresentation: Data { key.rawRepresentation }
    }
}

public extension SecretRequestCryptographer {
    
    convenience init(
        publicTransportKeyEncrypt: @escaping Encrypt
    ) {
        self.init(
            makeECDHKeys: Self.makeECDHKeys,
            encrypt: publicTransportKeyEncrypt
        )
    }
    
    static func makeECDHKeys() throws -> (saS: SaS, paS: PaS) {
        
        let privateKey = P384.KeyAgreement.PrivateKey()
        
//        let publicKeyData = privateKey.publicKey.rawRepresentation
//        let publicKey = try P384.KeyAgreement.PublicKey(
//            rawRepresentation: publicKeyData
//        )
        
        return (.init(key: privateKey), .init(key: privateKey.publicKey))
    }
}
