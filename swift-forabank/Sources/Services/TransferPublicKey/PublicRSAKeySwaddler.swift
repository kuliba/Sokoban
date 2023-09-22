//
//  PublicRSAKeySwaddler.swift
//  
//
//  Created by Igor Malyarov on 06.08.2023.
//

import Foundation

public protocol RawRepresentational {
    
    var rawRepresentation: Data { get throws }
}

public final class PublicRSAKeySwaddler<OTP, PrivateKey, PublicKey>
where PublicKey: RawRepresentational {
    
    public typealias GenerateRSA4096BitKeys = () throws -> (PrivateKey, PublicKey)
    public typealias SignEncryptOTP = (OTP, PrivateKey) throws -> Data
    public typealias SaveKeys = (PrivateKey, PublicKey) throws -> Void
    public typealias SharedSecret = SwaddleKeyDomain<OTP>.SharedSecret
    public typealias AESEncrypt128bitChunks = (Data, SharedSecret) throws -> Data
    
    private let generateRSA4096BitKeys: GenerateRSA4096BitKeys
    private let signEncryptOTP: SignEncryptOTP
    private let saveKeys: SaveKeys
    private let aesEncrypt128bitChunks: AESEncrypt128bitChunks
    
    public init(
        generateRSA4096BitKeys: @escaping GenerateRSA4096BitKeys,
        signEncryptOTP: @escaping SignEncryptOTP,
        saveKeys: @escaping SaveKeys,
        aesEncrypt128bitChunks: @escaping AESEncrypt128bitChunks
    ) {
        self.generateRSA4096BitKeys = generateRSA4096BitKeys
        self.signEncryptOTP = signEncryptOTP
        self.saveKeys = saveKeys
        self.aesEncrypt128bitChunks = aesEncrypt128bitChunks
    }
    
    public func swaddleKey(
        with otp: OTP,
        and sharedSecret: SharedSecret
    ) throws -> Data {
        
        let (encryptedSignedOTP, privateKey, publicKey) = try retrySignEncryptOTP(otp)
        
        try saveKeys(privateKey, publicKey)
        
        let publicKeyData = try publicKey.rawRepresentation
        
        let procClientSecretOTP = encryptedSignedOTP.base64EncodedString()
        let clientPublicKeyRSA = publicKeyData.base64EncodedString()
        
        let json = try JSONSerialization.data(withJSONObject: [
            "procClientSecretOTP": procClientSecretOTP,
            "clientPublicKeyRSA": clientPublicKeyRSA
        ] as [String: String])

        #if DEBUG
        print(">>> encryptedSignedOTP count: \(encryptedSignedOTP)\n>>> procClientSecretOTP.count: \(procClientSecretOTP.count)\n", #file, #line)
        dump(procClientSecretOTP)

        print(">>> publicKeyData count: \(publicKeyData.count)\n>>> clientPublicKeyRSA.count: \(clientPublicKeyRSA.count)\n", #file, #line)
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
