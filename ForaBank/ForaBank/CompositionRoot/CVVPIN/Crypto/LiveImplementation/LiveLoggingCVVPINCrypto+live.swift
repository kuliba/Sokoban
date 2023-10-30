//
//  LiveLoggingCVVPINCrypto+live.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.10.2023.
//

import ForaCrypto
import Foundation

extension LiveLoggingCVVPINCrypto {
    
    static func live(
        log: @escaping (String) -> Void
    ) -> Self {
        
        self.init(
            _generateP384KeyPair: _generateP384KeyPair,
            _generateRSA4096BitKeyPair: _generateRSA4096BitKeyPair,
            _publicKeyData: _publicKeyData(publicKey:),
            _transportEncrypt: _transportEncrypt(_:),
            _sharedSecret: _sharedSecret(string:privateKey:),
            log: log
        )
    }
    
    private static func _generateP384KeyPair(
    ) -> P384KeyAgreementDomain.KeyPair {
        
        ForaCrypto.Crypto.generateP384KeyPair()
    }
    
    private static func _generateRSA4096BitKeyPair() throws -> RSAKeyPair {
        
        try ForaCrypto.Crypto.generateKeyPair(
            keyType: .rsa,
            keySize: .bits4096
        )
    }
    
    private static func _publicKeyData(
        publicKey: PublicKey
    ) throws -> Data {
        
        let representation = publicKey.derRepresentation
        let log: (String) -> Void = { LoggerAgent.shared.log(level: .debug, category: .crypto, message: $0) }
        log("Public Key representation: \(representation)")
        return representation
    }
    
    private static func _transportEncrypt(
        _ data: Data
    ) throws -> Data {
        
        try ForaCrypto.Crypto.transportEncrypt(data, padding: .PKCS1)
    }
    
    private static func _sharedSecret(
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
