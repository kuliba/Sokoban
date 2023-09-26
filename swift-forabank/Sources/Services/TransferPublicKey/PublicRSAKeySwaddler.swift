//
//  PublicRSAKeySwaddler.swift
//  
//
//  Created by Igor Malyarov on 06.08.2023.
//

import Foundation

public final class PublicRSAKeySwaddler<OTP, PrivateKey, PublicKey> {
    
    public typealias GenerateRSA4096BitKeys = () throws -> (PrivateKey, PublicKey)
    public typealias SignEncryptOTP = (OTP, PrivateKey) throws -> Data
    public typealias SaveKeys = (PrivateKey, PublicKey) throws -> Void
    public typealias X509Representation = (PublicKey) throws -> Data
    public typealias SharedSecret = SwaddleKeyDomain<OTP>.SharedSecret
    public typealias AESEncrypt128bitChunks = (Data, SharedSecret) throws -> Data
    
    private let generateRSA4096BitKeys: GenerateRSA4096BitKeys
    private let signEncryptOTP: SignEncryptOTP
    private let saveKeys: SaveKeys
    private let x509Representation: X509Representation
    private let aesEncrypt128bitChunks: AESEncrypt128bitChunks
    
    public init(
        generateRSA4096BitKeys: @escaping GenerateRSA4096BitKeys,
        signEncryptOTP: @escaping SignEncryptOTP,
        saveKeys: @escaping SaveKeys,
        x509Representation: @escaping X509Representation,
        aesEncrypt128bitChunks: @escaping AESEncrypt128bitChunks
    ) {
        self.generateRSA4096BitKeys = generateRSA4096BitKeys
        self.signEncryptOTP = signEncryptOTP
        self.saveKeys = saveKeys
        self.x509Representation = x509Representation
        self.aesEncrypt128bitChunks = aesEncrypt128bitChunks
    }
    
    public func swaddleKey(
        with otp: OTP,
        and sharedSecret: SharedSecret
    ) throws -> Data {
        
        let (encryptedSignedOTP, privateKey, publicKey) = try retrySignEncryptOTP(otp)
        
        try saveKeys(privateKey, publicKey)
        
        let publicKeyX509Representation = try x509Representation(publicKey)
        
        let procClientSecretOTP = encryptedSignedOTP.base64EncodedString()
        let clientPublicKeyRSA = publicKeyX509Representation.base64EncodedString()
        
        let json = try JSONSerialization.data(withJSONObject: [
            "procClientSecretOTP": procClientSecretOTP,
            "clientPublicKeyRSA": clientPublicKeyRSA
        ] as [String: String])

        #if DEBUG
        print(">>> encryptedSignedOTP count: \(encryptedSignedOTP)\n>>> procClientSecretOTP.count: \(procClientSecretOTP.count)\n", #file, #line)
        dump(procClientSecretOTP)

        print(">>> publicKeyData count: \(publicKeyX509Representation.count)\n>>> clientPublicKeyRSA.count: \(clientPublicKeyRSA.count)\n", #file, #line)
        dump(clientPublicKeyRSA)
        print(">>> json:\n", String(data: json, encoding: .utf8)!)
        #endif

        let data: Data = try aesEncrypt128bitChunks(json, sharedSecret)
        
        return data
    }
    
    private func retrySignEncryptOTP(
        _ otp: OTP
    ) throws -> (Data, PrivateKey, PublicKey) {
        
        try retry {
            
            let (privateKey, publicKey) = try generateRSA4096BitKeys()
            let encryptedSignedOTP = try signEncryptOTP(otp, privateKey)
            
            return (encryptedSignedOTP, privateKey, publicKey)
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
