//
//  KeyExchangeCryptographer+live.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.09.2023.
//

import VortexCrypto
import Foundation

extension KeyExchangeCryptographer {
    
    static let live: Self = .init(
        generateP384KeyPair: generateP384KeyPair,
        publicKeyData: publicKeyData,
        transportEncrypt: transportEncrypt,
        sharedSecret: sharedSecret
    )
    
    private static func generateP384KeyPair(
    ) -> P384KeyAgreementDomain.KeyPair {
        
        VortexCrypto.Crypto.generateP384KeyPair()
    }
    
    private static func publicKeyData(
        publicKey: PublicKey
    ) throws -> Data {
        
        let representation = publicKey.derRepresentation
        let log: (String) -> Void = { LoggerAgent.shared.log(level: .debug, category: .crypto, message: $0) }
        log("Public Key representation: \(representation)")
        return representation
    }
    
    private static func transportEncrypt(
        _ data: Data
    ) throws -> Data {
        
        try VortexCrypto.Crypto.transportEncrypt(data, padding: .PKCS1)
    }
    
    private static func sharedSecret(
        string: String,
        privateKey: PrivateKey
    ) throws -> Data {
        
        let serverPublicKey = try VortexCrypto.Crypto.transportDecryptP384PublicKey(from: string)
        let sharedSecret = try VortexCrypto.Crypto.sharedSecret(
            privateKey: privateKey,
            publicKey: serverPublicKey
        )
        
        return sharedSecret
    }
}
