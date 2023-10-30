//
//  CVVPINCrypto+live.swift
//  ForaBank
//
//  Created by Igor Malyarov on 18.10.2023.
//

import CVVPINServices
import ForaCrypto
import Foundation

extension CVVPINServices.CVVPINCrypto {
    
    static func live(
        httpClient: HTTPClient
    ) -> Self {
        
        .init(
            publicTransportDecrypt: publicTransportDecrypt(data:),
            encryptWithProcessingPublicRSAKey: encryptWithProcessingPublicRSAKey(data:),
            makeSymmetricKey: makeSymmetricKey(data:withKey:),
            makeECDHKeyPair: makeECDHKeyPair,
            aesEncrypt: aesEncrypt(data:withKey:),
            rsaEncrypt: rsaEncrypt(data:withKey:),
            rsaDecrypt: rsaDecrypt(data:withKey:),
            sign: sign(data:withKey:),
            createSignature: createSignature(signedData:withKey:),
            verify: verify(signedData:signature:withKey:),
            sha256Hash: sha256Hash(_:)
        )
    }
    
    /// `PublicTransportDecrypt`: (Data) throws -> Data
    ///
    /// Alternatives:
    ///
    /// - `ForaCrypto.Crypto.transportEncrypt(_:)`
    /// - `ForaCrypto.Crypto.transportEncrypt(_:padding:)`
    ///
    private static func publicTransportDecrypt(
        data: Data
    ) throws -> Data {
        
        let transportKey = try ForaCrypto.Crypto.transportKey()
        
        return try ForaCrypto.Crypto.encrypt(
            data: data,
            withPublicKey: transportKey,
            algorithm: .rsaEncryptionRaw
        )
    }
    
    private static func encryptWithProcessingPublicRSAKey(
        data: Data
    ) throws -> Data {
        
        let processingKey = try ForaCrypto.Crypto.processingKey()
        
        return try ForaCrypto.Crypto.encrypt(
            data: data,
            withPublicKey: processingKey,
            algorithm: .rsaEncryptionRaw
        )
    }
    
    private static func makeSymmetricKey(
        data: Data,
        withKey ecdhPrivateKey: ECDHPrivateKey
    ) throws -> SymmetricKey {
        
        unimplemented()
    }
    
    private static func makeECDHKeyPair() throws -> KeyPairDomain<ECDHPublicKey, ECDHPrivateKey>.KeyPair {
        
        unimplemented()
    }
    
    private static func aesEncrypt(
        data: Data,
        withKey symmetricKey: SymmetricKey
    ) throws -> Data {
        
        unimplemented()
    }
    
    private static func rsaEncrypt(
        data: Data,
        withKey rsaPrivateKey: RSAPrivateKey
    ) throws -> Data {
        
        unimplemented()
    }
    
    private static func rsaDecrypt(
        data: Data,
        withKey rsaPrivateKey: RSAPrivateKey
    ) throws -> Data {
        
        unimplemented()
    }
    
    private static func sign(
        data: Data,
        withKey rsaPrivateKey: RSAPrivateKey
    ) throws -> Data {
        
        unimplemented()
    }
    
    private static func createSignature(
        signedData: SignedData,
        withKey rsaPrivateKey: RSAPrivateKey
    ) throws -> Signature {
        
        unimplemented()
    }
    
    private static func verify(
        signedData: SignedData,
        signature:Signature,
        withKey rsaPublicKey: RSAPublicKey
    ) throws -> Bool {
        
        unimplemented()
    }
    
    private static func sha256Hash(
        _ string: String
    ) -> Data {
        
        unimplemented()
    }
}
