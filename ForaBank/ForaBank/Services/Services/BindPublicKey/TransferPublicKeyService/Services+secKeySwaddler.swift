//
//  Services+secKeySwaddler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.09.2023.
//

import ForaCrypto
import Foundation
import TransferPublicKey

extension Services {
    
    typealias SecKeySwaddler = PublicRSAKeySwaddler<TransferOTP, SecKey, SecKey>
    
    static func secKeySwaddler() -> SecKeySwaddler {
        
        let generateRSA4096BitKeys = {
            
            try ForaCrypto.Crypto.createRandomSecKeys(
                keyType: kSecAttrKeyTypeRSA,
                keySizeInBits: 4096
            )
        }
        
        let transportKeyEncrypt: (Data) throws -> Data = {
            
            let encrypted = try ForaCrypto.Crypto.rsaEncrypt(
                data: $0,
                withPublicKey: ForaCrypto.Crypto.transportKey(),
                algorithm: .rsaEncryptionRaw
            )
            LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Encrypted with transport public key: \(encrypted)")
            
            return encrypted
        }
        
        let signEncryptOTP: SecKeySwaddler.SignEncryptOTP = { otp, privateKey in
            
            let clientSecretOTP = try ForaCrypto.Crypto.sign(
                .init(otp.value.utf8),
                withPrivateKey: privateKey,
                algorithm: .rsaSignatureDigestPKCS1v15SHA256
            )
            LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Create \"clientSecretOTP\" (signed OTP): \(clientSecretOTP)")
            
            let procClientSecretOTP = try transportKeyEncrypt(
                clientSecretOTP
            )
            LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Create \"procClientSecretOTP\" (encrypted \"clientSecretOTP\"): \(procClientSecretOTP)")
            
            return procClientSecretOTP
        }
        
        let keyCache = InMemoryKeyStore<SecKey>()
        let saveKeys: SecKeySwaddler.SaveKeys = { privateKey, publicKey in
            
            keyCache.saveKey(privateKey) { _ in
                #warning("FIX THIS")
            }
        }
        
        let aesEncrypt128bitChunks: SecKeySwaddler.AESEncrypt128bitChunks = { data, secret in
            
            let aes256CBC = try ForaCrypto.AES256CBC(key: secret.data)
            LoggerAgent.shared.log(level: .debug, category: .crypto, message: "Create AES256CBC with key \"\(secret.data)\"")
            
            let result = try aes256CBC.encrypt(data)
            LoggerAgent.shared.log(level: .debug, category: .crypto, message: "AES encrypt data \"\(data)\"")
            
            return result
        }
        
        return .init(
            generateRSA4096BitKeys: generateRSA4096BitKeys,
            signEncryptOTP: signEncryptOTP,
            saveKeys: saveKeys,
            aesEncrypt128bitChunks: aesEncrypt128bitChunks
        )
    }
}
