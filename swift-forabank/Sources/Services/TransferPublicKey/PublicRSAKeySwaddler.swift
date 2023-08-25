//
//  PublicRSAKeySwaddler.swift
//  
//
//  Created by Igor Malyarov on 06.08.2023.
//

import Foundation

public protocol RawRepresentational {
    
    var rawRepresentation: Data { get }
}

public final class PublicRSAKeySwaddler<OTP, PrivateKey, PublicKey>
where PublicKey: RawRepresentational {
    
    public typealias GenerateRSA4096BitKeys = () throws -> (PrivateKey, PublicKey)
    public typealias EncryptOTPWithRSAKey = (OTP, PrivateKey) throws -> Data
    public typealias SaveKeys = (PrivateKey, PublicKey) throws -> Void
    public typealias SharedSecret = SwaddleKeyDomain<OTP>.SharedSecret
    public typealias AESEncryptBits128Chunks = (Data, SharedSecret) throws -> Data
    
    private let generateRSA4096BitKeys: GenerateRSA4096BitKeys
    private let encryptOTPWithRSAKey: EncryptOTPWithRSAKey
    private let saveKeys: SaveKeys
    private let aesEncrypt128bitChunks: AESEncryptBits128Chunks
    
    public init(
        generateRSA4096BitKeys: @escaping GenerateRSA4096BitKeys,
        encryptOTPWithRSAKey: @escaping EncryptOTPWithRSAKey,
        saveKeys: @escaping SaveKeys,
        aesEncrypt128bitChunks: @escaping AESEncryptBits128Chunks
    ) {
        self.generateRSA4096BitKeys = generateRSA4096BitKeys
        self.encryptOTPWithRSAKey = encryptOTPWithRSAKey
        self.saveKeys = saveKeys
        self.aesEncrypt128bitChunks = aesEncrypt128bitChunks
    }
    
    public func swaddleKey(
        with otp: OTP,
        and sharedSecret: SharedSecret
    ) throws -> Data {
        
        let (encryptedOTP, privateKey, publicKey) = try retryEncryptOTP(otp)
        
        try saveKeys(privateKey, publicKey)
        
        let publicKeyData = publicKey.rawRepresentation
        
        let json = try JSONSerialization.data(withJSONObject: [
            "procClientSecretOTP": encryptedOTP.base64EncodedString(),
            "clientPublicKeyRSA": publicKeyData.base64EncodedString()
        ] as [String: String])
        
        let data: Data = try aesEncrypt128bitChunks(json, sharedSecret)
        
        return data
    }
    
    private func retryEncryptOTP(
        _ otp: OTP
    ) throws -> (Data, PrivateKey, PublicKey) {
        
        try retry {
            
            let (privateKey, publicKey) = try generateRSA4096BitKeys()
            let encryptedOTP = try encryptOTPWithRSAKey(otp, privateKey)
            
            return (encryptedOTP, privateKey, publicKey)
        }
    }
    
#warning("this might already be a part of make...Request")
    func makeSecretJSON(
        eventID: EventID,
        data: Data
    ) throws -> Data {
        
        let json = try JSONSerialization.data(withJSONObject: [
            "eventId": eventID.value,
            "data": data.base64EncodedString()
        ] as [String: Any])
        
        return json
    }
}

struct EventID {
    
    let value: String
}
