//
//  KeyExchangeCryptographer+live.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import ForaCrypto
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
        
        ForaCrypto.Crypto.generateP384KeyPair()
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
        
        try ForaCrypto.Crypto.transportEncrypt(data, padding: .PKCS1)
    }
    
    private static func sharedSecret(
        string: String,
        privateKey: PrivateKey
    ) throws -> Data {
        
        let serverPublicKey = try ForaCrypto.Crypto.transportDecryptP384PublicKey(from: string)
        let sharedSecret = try ForaCrypto.Crypto.sharedSecret(
            privateKey: privateKey,
            publicKey: serverPublicKey
        )
        
        return sharedSecret
    }
}
