//
//  CVVPINCrypto+test.swift
//  
//
//  Created by Igor Malyarov on 09.10.2023.
//

import CVVPINServices
import Foundation

extension CVVPINCrypto<ECDHPublicKey, ECDHPrivateKey, RSAPublicKey, RSAPrivateKey, SymmetricKey> {
    
    static func test(
        publicTransportDecrypt: PublicTransportDecrypt? = nil,
        encryptWithProcessingPublicRSAKey: EncryptWithProcessingPublicRSAKey? = nil,
        makeSymmetricKey: MakeSymmetricKey? = nil,
        makeECDHKeyPair: ECDHKeyPairDomain.Get? = nil,
        aesEncrypt: AESEncrypt? = nil,
        rsaEncrypt: RSAEncrypt? = nil,
        rsaDecrypt: RSADecrypt? = nil,
        sign: Sign? = nil,
        createSignature: CreateSignature? = nil,
        verify: Verify? = nil,
        sha256Hash: SHA256Hash? = nil
    ) -> Self {
        
        .init(
            publicTransportDecrypt: publicTransportDecrypt ?? _publicTransportDecrypt,
            encryptWithProcessingPublicRSAKey: encryptWithProcessingPublicRSAKey ?? _encryptWithProcessingPublicRSAKey,
            makeSymmetricKey: makeSymmetricKey ?? _makeSymmetricKey,
            makeECDHKeyPair: makeECDHKeyPair ?? _makeECDHKeyPair,
            aesEncrypt: aesEncrypt ?? _aesEncrypt,
            rsaEncrypt: rsaEncrypt ?? _rsaEncrypt,
            rsaDecrypt: rsaDecrypt ?? _rsaDecrypt,
            sign: sign ?? _sign,
            createSignature: createSignature ?? _createSignature,
            verify: verify ?? _verify,
            sha256Hash: sha256Hash ?? _sha256Hash
        )
    }
    
    private static func _publicTransportDecrypt(
        data: Data
    ) throws -> Data {
        
        data
    }
    
    private static func _encryptWithProcessingPublicRSAKey(
        data: Data
    ) throws -> Data {
        
        data
    }
    
    private static func _makeSymmetricKey(
        data: Data,
        ecdhPrivateKey: ECDHPrivateKey
    ) throws -> SymmetricKey {
        
        .init("Symmetric Session Key")
    }

    private static func _makeECDHKeyPair(
    ) throws -> KeyPairDomain<ECDHPublicKey, ECDHPrivateKey>.KeyPair {
        
        (.init("ECDH Public Key"), .init("ECDH Private Key"))
    }
    
    private static let aesSuffix: Data = .init("==".utf8)
    
    private static func _aesEncrypt(
        data: Data,
        symmetricKey: SymmetricKey
    ) throws -> Data {
        
        var data = data
        data.append(aesSuffix)
        return data
    }
    
    private static func _rsaEncrypt(
        data: Data,
        rsaPrivateKey: RSAPrivateKey
    ) throws -> Data {
        
        data
    }
    
    private static func _rsaDecrypt(
        data: Data,
        rsaPrivateKey: RSAPrivateKey
    ) throws -> Data {
        
        data
    }
    
    private static let signSuffix: Data = .init("=".utf8)
    
    private static func _sign(
        data: Data,
        rsaPrivateKey: RSAPrivateKey
    ) throws -> Data {
        
        var data = data
        data.append(signSuffix)
        return data
    }
    
    private static let signatureSuffix: Data = .init("=".utf8)
    
    private static func _createSignature(
        signedData: SignedData,
        rsaPrivateKey: RSAPrivateKey
    ) throws -> Signature {
        
        var signedData = signedData
        signedData.append(signatureSuffix)
        return signedData
    }
    
    private static func _verify(
        signedData: SignedData,
        signature: Signature,
        rsaPublicKey: RSAPublicKey
    ) throws -> Bool {
        
        true
    }
    
    private static func _sha256Hash(
        string: String
    ) -> Data {
        
        .init(string.utf8)
    }
}
