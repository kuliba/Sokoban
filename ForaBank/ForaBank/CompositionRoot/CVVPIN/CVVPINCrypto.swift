//
//  CVVPINCrypto.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import Foundation

// TODO: make generic to decouple from ForaCrypto
protocol CVVPINCrypto {
    
    typealias ECDHPublicKey = ECDHDomain.PublicKey
    typealias ECDHPrivateKey = ECDHDomain.PrivateKey
    typealias ECDHKeyPair = ECDHDomain.KeyPair
    
    typealias RSAPublicKey = RSADomain.PublicKey
    typealias RSAPrivateKey = RSADomain.PrivateKey
    typealias RSAKeyPair = RSADomain.KeyPair
        
    // MARK: - Transport Key Domain
    
    func transportEncrypt(data: Data) throws -> Data
    
#warning("there is transportEncrypt")
    func transportKeyEncrypt(_ data: Data) throws -> Data
    
    // MARK: - ECDH Domain
    
    #warning("rename to `generateECDHKeyPair")
    func generateP384KeyPair() -> ECDHKeyPair
    
    /// Used if `AuthenticateWithPublicKeyService`
    func extractSharedSecret(
        from string: String,
        using privateKey: ECDHPrivateKey
    ) throws -> Data
    
    /// `formSessionKey`
    func publicKeyData(
        forPublicKey publicKey: ECDHPublicKey
    ) throws -> Data
    
    // MARK: - RSA Domain
    
    /// `ChangePINSecretJSON`
    func generateRSA4096BitKeyPair() throws -> RSAKeyPair
    
    /// `ChangePINCrypto`
    func rsaDecrypt(
        _ string: String,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> String
    
    func signEncryptOTP(
        otp: String,
        privateKey: RSAPrivateKey
    ) throws -> Data
    
    func x509Representation(
        publicKey: RSAPublicKey
    ) throws -> Data

    // MARK: - AES
    
    func aesEncrypt(
        data: Data,
        sessionKey: SessionKey
    ) throws -> Data
}
