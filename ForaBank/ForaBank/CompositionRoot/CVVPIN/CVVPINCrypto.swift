//
//  CVVPINCrypto.swift
//  ForaBank
//
//  Created by Igor Malyarov on 29.10.2023.
//

import ForaCrypto
import Foundation

// TODO: make generic to decouple from ForaCrypto
protocol CVVPINCrypto {
    
    typealias PublicKey = P384KeyAgreementDomain.PublicKey
    typealias PrivateKey = P384KeyAgreementDomain.PrivateKey
    
    typealias RSAKeyPair = (publicKey: SecKey, privateKey: SecKey)
    
    func generateP384KeyPair() -> P384KeyAgreementDomain.KeyPair
    
    /// Used if `AuthenticateWithPublicKeyService`
    func makeSharedSecret(
        from string: String,
        using privateKey: P384KeyAgreementDomain.PrivateKey
    ) throws -> Data
    
    /// `formSessionKey`
    func publicKeyData(forPublicKey publicKey: PublicKey) throws -> Data
    func transportEncrypt(data: Data) throws -> Data
    
    /// `ChangePINSecretJSON`
    func generateRSA4096BitKeyPair() throws -> RSAKeyPair
    func signEncryptOTP(otp: String, privateKey: SecKey) throws -> Data
    func transportKeyEncrypt(_ data: Data) throws -> Data
    func x509Representation(publicKey: SecKey) throws -> Data
    func aesEncrypt(data: Data, sessionKey: SessionKey) throws -> Data

    /// `ChangePINCrypto`
    func rsaDecrypt(
        _ string: String,
        withPrivateKey privateKey: SecKey
    ) throws -> String
}
