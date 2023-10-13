//
//  KeyExchange.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

import CryptoKit
import Foundation

public struct KeyExchange<ECDHPublicKey, ECDHPrivateKey, RSAPublicKey, RSAPrivateKey, SymmetricKey>
where ECDHPublicKey: RawRepresentable<Data>,
      RSAPublicKey: RawRepresentable<Data> {
    
    public typealias ECDHKeyPairDomain = KeyPairDomain<ECDHPublicKey, ECDHPrivateKey>
    public typealias MakeECDHKeyPair = ECDHKeyPairDomain.Get
    public typealias Sign = (Data, RSAPrivateKey) throws -> Data
    public typealias PublicKeyAuthDomain = RemoteServiceDomain<Data, PublicKeyAuthenticationResponse, Error>
    public typealias Process = PublicKeyAuthDomain.AsyncGet
    public typealias MakeSymmetricKey = (PublicKeyAuthenticationResponse, ECDHPrivateKey) throws -> SymmetricKey
    
    private let makeECDHKeyPair: MakeECDHKeyPair
    private let sign: Sign
    private let process: Process
    private let makeSymmetricKey: MakeSymmetricKey
    
    public init(
        makeECDHKeyPair: @escaping MakeECDHKeyPair,
        sign: @escaping Sign,
        process: @escaping Process,
        makeSymmetricKey: @escaping MakeSymmetricKey
    ) {
        self.makeECDHKeyPair = makeECDHKeyPair
        self.sign = sign
        self.process = process
        self.makeSymmetricKey = makeSymmetricKey
    }
}

public extension KeyExchange {
    
    typealias RSAKeyPairDomain = KeyPairDomain<RSAPublicKey, RSAPrivateKey>
    typealias SymmetricKeyDomain = DomainOf<SymmetricKey>
    typealias Completion = SymmetricKeyDomain.Completion
    
    func exchangeKeys(
        rsaKeyPair: RSAKeyPairDomain.KeyPair,
        completion: @escaping Completion
    ) {
        do {
            let (paS, saS) = try makeECDHKeyPair()
            let (clientPublicKeyRSA, privateKey) = rsaKeyPair
            
            let json = try KeyExchangeHelper.wrapInJSON(
                clientPublicKeyRSABase64: clientPublicKeyRSA.rawValue.base64EncodedString(),
                publicApplicationSessionKeyBase64: paS.rawValue.base64EncodedString(),
                signWithClientSecretKey: { try sign($0, privateKey) }
            )
            
            // processPublicKeyAuthenticationRequest
            process(json) { result in
                
                completion(.init {
                    
                    try makeSymmetricKey(result.get(), saS)
                })
            }
        } catch {
            completion(.failure(error))
        }
    }
}

enum KeyExchangeHelper {
    
    static func wrapInJSON(
        clientPublicKeyRSABase64: String,
        publicApplicationSessionKeyBase64: String,
        signWithClientSecretKey: @escaping (Data) throws -> Data
    ) throws -> Data {
        
        // make SHA256 hash of concatenation of base 64 strings of
        // - clientPublicKeyRSA (CLIENT-PUBLIC-KEY) and
        // - publicApplicationSessionKey (PaS)
        let concatenation = clientPublicKeyRSABase64 + publicApplicationSessionKeyBase64
        let data = Data(concatenation.utf8)
        // looks like `SHA256.hash(data:)` is not used
        // let hash = SHA256.hash(data: data)
        
        // sign hash with CLIENT-SECRET-KEY
        let signature = try signWithClientSecretKey(data)
        
        let json = try JSONSerialization.data(withJSONObject: [
            // String(1024): BASE64 encoded CLIENT-PUBLIC-KEY
            "clientPublicKeyRSA": clientPublicKeyRSABase64,
            // String(1024): BASE64 encoded зашифрованный PaS
            "publicApplicationSessionKey": publicApplicationSessionKeyBase64,
            // String(1024): BASE64-строка с цифровой подписью
            "signature": signature.base64EncodedString()
        ] as [String: String])
        
        return json
    }
}
