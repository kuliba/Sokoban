//
//  SecKeySwaddleCryptographer+live.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.09.2023.
//

import Foundation
import ForaCrypto

extension SecKeySwaddleCryptographer {
    
    static let live: Self = .init(
        generateRSA4096BitKeys: generateRSA4096BitKeys,
        signEncryptOTP: signEncryptOTP,
        saveKeys: saveKeys,
        x509Representation: x509Representation,
        aesEncrypt128bitChunks: aesEncrypt128bitChunks
    )
    
    private static func generateRSA4096BitKeys(
    ) throws -> (privateKey: SecKey, publicKey: SecKey)  {
        
        try ForaCrypto.Crypto.createRandomSecKeys(
            keyType: .rsa,
            keySize: .bits4096
        )
    }
    
    private static func signEncryptOTP(
        otp: Services.TransferOTP,
        privateKey: SecKey
    ) throws -> Data {
        
        let clientSecretOTP = try ForaCrypto.Crypto.signNoHash(
            .init(otp.value.utf8),
            withPrivateKey: privateKey,
            algorithm: .rsaSignatureDigestPKCS1v15Raw
        )
        LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Create \"clientSecretOTP\" (signed OTP): \(clientSecretOTP)")
        
        let procClientSecretOTP = try transportKeyEncrypt(
            clientSecretOTP
        )
        LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Create \"procClientSecretOTP\" (encrypted \"clientSecretOTP\"): \(procClientSecretOTP)")
        
        return procClientSecretOTP
    }
    
    private static func transportKeyEncrypt(
        _ data: Data
    ) throws -> Data {
        
        do {
            let transportKey = try ForaCrypto.Crypto.transportKey()
            
            let encrypted = try ForaCrypto.Crypto.encrypt(
                data: data,
                withPublicKey: transportKey,
                algorithm: .rsaEncryptionRaw
            )
            LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Encrypted with transport public key: \(encrypted)")
            
            return encrypted
        } catch {
            LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Transport public key encryption error: \(error.localizedDescription)")
            throw error
        }
    }
    
    private static func saveKeys(
        privateKey: SecKey,
        publicKey: SecKey
    ) throws {
        
        let keyCache = InMemoryKeyStore<SecKey>()
        
        keyCache.saveKey(privateKey) { _ in
            
            #warning("FIX THIS")
        }
    }
    
    private static func x509Representation(
        publicKey: SecKey
    ) throws -> Data {
        
        let x509Representation = try ForaCrypto.Crypto.x509Representation(of: publicKey)
        LoggerAgent.shared.log(level: .debug, category: .crypto, message: "x509Representation of \(publicKey) is \"\(x509Representation.base64EncodedString())\".")

        return x509Representation
    }
    
    private static func aesEncrypt128bitChunks(
        data: Data,
        secret: SecKeySwaddler.SharedSecret
    ) throws -> Data {
        
        let aes256CBC = try ForaCrypto.AES256CBC(key: secret.data)
        LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Create AES256CBC with key \"\(secret.data)\"")
        
        let result = try aes256CBC.encrypt(data)
        LoggerAgent.shared.log(level: .debug, category: .crypto, message: "AES encrypted data \"\(data)\" with result \"\(result.base64EncodedString())\".")
        
        return result
    }
}

