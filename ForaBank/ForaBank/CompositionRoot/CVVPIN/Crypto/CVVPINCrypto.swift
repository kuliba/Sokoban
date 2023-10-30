//
//  CVVPINCrypto.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import Foundation

protocol CVVPINCrypto {
    
    typealias ECDHPublicKey = ECDHDomain.PublicKey
    typealias ECDHPrivateKey = ECDHDomain.PrivateKey
    typealias ECDHKeyPair = ECDHDomain.KeyPair
    
    typealias RSAPublicKey = RSADomain.PublicKey
    typealias RSAPrivateKey = RSADomain.PrivateKey
    typealias RSAKeyPair = RSADomain.KeyPair
    
    // MARK: - Transport Key Domain
    
    func transportEncryptWithPadding(data: Data) throws -> Data
    
    func transportEncryptNoPadding(data: Data) throws -> Data
    
    // MARK: - ECDH Domain
    
    func generateECDHKeyPair() -> ECDHKeyPair
    
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
    
    func signNoHash(
        _ data: Data,
        withPrivateKey privateKey: RSAPrivateKey
    ) throws -> Data
    
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
    
    // MARK: - Hash
    
    func hash(_ data: Data) -> Data
}
