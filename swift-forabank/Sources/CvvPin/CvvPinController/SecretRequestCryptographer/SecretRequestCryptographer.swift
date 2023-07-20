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
            
            let data = try Self.wrap(paS, andEncrypt: encrypt)
            
            return .init(
                code: .init(value: sessionCode.value),
                data: data
            )
        })
    }
    
    public static func wrap(
        _ paS: PaS,
        andEncrypt encrypt: Encrypt
    ) throws -> Data {
        
        let base64 = paS.rawRepresentation.base64EncodedString()
        let pasKey = "publicApplicationSessionKey"
        let json: [String: Any] = [pasKey: base64]
        let data = try JSONSerialization.data(withJSONObject: json)
        
        return try encrypt(data)
    }
    
    public struct SaS {
        
        public let key: P384.Signing.PrivateKey
    }
    
    public struct PaS {
        
        public let key: P384.Signing.PublicKey
        
        public init(key: P384.Signing.PublicKey) {
            
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
        
        let privateKey = P384.Signing.PrivateKey()
        
        let publicKeyData = privateKey.publicKey.rawRepresentation
        let publicKey = try P384.Signing.PublicKey(
            rawRepresentation: publicKeyData
        )
        
        return (.init(key: privateKey), .init(key: publicKey))
    }
}
