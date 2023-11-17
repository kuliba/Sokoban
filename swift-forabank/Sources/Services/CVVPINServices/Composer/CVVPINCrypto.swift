//
//  CVVPINCrypto.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

import Foundation

public struct CVVPINCrypto<ECDHPublicKey, ECDHPrivateKey, RSAPublicKey, RSAPrivateKey, SymmetricKey> {
    
    public typealias PublicTransportDecrypt = (Data) throws -> Data
    public typealias EncryptWithProcessingPublicRSAKey = (Data) throws -> Data
    
    public typealias MakeSymmetricKey = (Data, ECDHPrivateKey) throws -> SymmetricKey
    public typealias ECDHKeyPairDomain = KeyPairDomain<ECDHPublicKey, ECDHPrivateKey>
    
    public typealias AESEncrypt = (Data, SymmetricKey) throws -> Data
    
#warning("both RSAEncrypt and RSADecrypt use RSAPrivateKey")
    public typealias RSAEncrypt = (Data, RSAPrivateKey) throws -> Data
    public typealias RSADecrypt = (Data, RSAPrivateKey) throws -> Data
    public typealias Sign = (Data, RSAPrivateKey) throws -> Data
    public typealias SignedData = Data
    public typealias Signature = Data
    public typealias CreateSignature = (SignedData, RSAPrivateKey) throws -> Signature
    public typealias Verify = (SignedData, Signature, RSAPublicKey) throws -> Bool
    
    public typealias SHA256Hash = (String) -> Data
    
    let publicTransportDecrypt: PublicTransportDecrypt
    let encryptWithProcessingPublicRSAKey: EncryptWithProcessingPublicRSAKey

    let makeSymmetricKey: MakeSymmetricKey
    let makeECDHKeyPair: ECDHKeyPairDomain.Get
    
    let aesEncrypt: AESEncrypt
    
    let rsaEncrypt: RSAEncrypt
    let rsaDecrypt: RSADecrypt
    let sign: Sign
    let createSignature: CreateSignature
    let verify: Verify
    
    let sha256Hash: SHA256Hash
    
    public init(
        publicTransportDecrypt: @escaping PublicTransportDecrypt,
        encryptWithProcessingPublicRSAKey: @escaping EncryptWithProcessingPublicRSAKey,
        makeSymmetricKey: @escaping MakeSymmetricKey,
        makeECDHKeyPair: @escaping ECDHKeyPairDomain.Get,
        aesEncrypt: @escaping AESEncrypt,
        rsaEncrypt: @escaping RSAEncrypt,
        rsaDecrypt: @escaping RSADecrypt,
        sign: @escaping Sign,
        createSignature: @escaping CreateSignature,
        verify: @escaping Verify,
        sha256Hash: @escaping SHA256Hash
    ) {
        self.publicTransportDecrypt = publicTransportDecrypt
        self.encryptWithProcessingPublicRSAKey = encryptWithProcessingPublicRSAKey
        self.makeSymmetricKey = makeSymmetricKey
        self.makeECDHKeyPair = makeECDHKeyPair
        self.aesEncrypt = aesEncrypt
        self.rsaEncrypt = rsaEncrypt
        self.rsaDecrypt = rsaDecrypt
        self.sign = sign
        self.createSignature = createSignature
        self.verify = verify
        self.sha256Hash = sha256Hash
    }
}

