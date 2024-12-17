//
//  AESEncryptionAgent.swift
//  ForaBank
//
//  Created by Max Gribov on 12.02.2022.
//

import Foundation
import CommonCrypto

struct AESEncryptionAgent: EncryptionAgent {
    
    private let key: Data
    private let ivSize: Int = kCCBlockSizeAES128
    private let options: CCOptions = CCOptions(kCCOptionPKCS7Padding)

    init(with keyData: Data) {
        
        self.key = keyData
    }
}

extension AESEncryptionAgent {
    
    func encrypt(_ data: Data) throws -> Data {
        
        let bufferSize: Int = ivSize + data.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        try generateRandomIV(for: &buffer)

        var numberBytesEncrypted: Int = 0

        do {
            try key.withUnsafeBytes { keyBytes in
                try data.withUnsafeBytes { dataToEncryptBytes in
                    try buffer.withUnsafeMutableBytes { bufferBytes in

                        guard let keyBytesBaseAddress = keyBytes.baseAddress,
                            let dataToEncryptBytesBaseAddress = dataToEncryptBytes.baseAddress,
                            let bufferBytesBaseAddress = bufferBytes.baseAddress else {
                                throw AESEncryptionAgentError.encryptionFailed
                        }

                        let cryptStatus: CCCryptorStatus = CCCrypt( // Stateless, one-shot encrypt operation
                            CCOperation(kCCEncrypt),                // op: CCOperation
                            CCAlgorithm(kCCAlgorithmAES),           // alg: CCAlgorithm
                            options,                                // options: CCOptions
                            keyBytesBaseAddress,                    // key: the "password"
                            key.count,                              // keyLength: the "password" size
                            bufferBytesBaseAddress,                 // iv: Initialization Vector
                            dataToEncryptBytesBaseAddress,          // dataIn: Data to encrypt bytes
                            dataToEncryptBytes.count,               // dataInLength: Data to encrypt size
                            bufferBytesBaseAddress + ivSize,        // dataOut: encrypted Data buffer
                            bufferSize,                             // dataOutAvailable: encrypted Data buffer size
                            &numberBytesEncrypted                   // dataOutMoved: the number of bytes written
                        )

                        guard cryptStatus == CCCryptorStatus(kCCSuccess) else {
                            throw AESEncryptionAgentError.encryptionFailed
                        }
                    }
                }
            }

        } catch {
            
            throw AESEncryptionAgentError.encryptionFailed
        }

        let encryptedData: Data = buffer[..<(numberBytesEncrypted + ivSize)]
        
        return encryptedData
    }
}

extension AESEncryptionAgent {
    
    func decrypt(_ data: Data) throws -> Data {
        
        let newData = data
        let bufferSize: Int = newData.count - ivSize
        var buffer = Data(count: bufferSize)

        var numberBytesDecrypted: Int = 0
      
        do {
            try key.withUnsafeBytes { keyBytes in
                try newData.withUnsafeBytes { dataToDecryptBytes in
                    try buffer.withUnsafeMutableBytes { bufferBytes in

                        guard let keyBytesBaseAddress = keyBytes.baseAddress,
                            let dataToDecryptBytesBaseAddress = dataToDecryptBytes.baseAddress,
                            let bufferBytesBaseAddress = bufferBytes.baseAddress else {
                                throw AESEncryptionAgentError.encryptionFailed
                        }

                        let cryptStatus: CCCryptorStatus = CCCrypt( // Stateless, one-shot encrypt operation
                            CCOperation(kCCDecrypt),                // op: CCOperation
                            CCAlgorithm(kCCAlgorithmAES128),        // alg: CCAlgorithm
                            options,                                // options: CCOptions
                            keyBytesBaseAddress,                    // key: the "password"
                            key.count,                              // keyLength: the "password" size
                            dataToDecryptBytesBaseAddress,          // iv: Initialization Vector
                            dataToDecryptBytesBaseAddress + ivSize, // dataIn: Data to decrypt bytes
                            bufferSize,                             // dataInLength: Data to decrypt size
                            bufferBytesBaseAddress,                 // dataOut: decrypted Data buffer
                            bufferSize,                             // dataOutAvailable: decrypted Data buffer size
                            &numberBytesDecrypted                   // dataOutMoved: the number of bytes written
                        )

                        guard cryptStatus == CCCryptorStatus(kCCSuccess) else {
                            throw AESEncryptionAgentError.decryptionFailed
                        }
                    }
                }
            }
            
        } catch {
            
            throw AESEncryptionAgentError.encryptionFailed
        }

        let decryptedData: Data = buffer[..<numberBytesDecrypted]

        return decryptedData
    }
}

private extension AESEncryptionAgent {

    func generateRandomIV(for data: inout Data) throws {

        try data.withUnsafeMutableBytes { dataBytes in

            guard let dataBytesBaseAddress = dataBytes.baseAddress else {
                throw AESEncryptionAgentError.generateRandomIVFailed
            }

            let status: Int32 = SecRandomCopyBytes(
                kSecRandomDefault,
                kCCBlockSizeAES128,
                dataBytesBaseAddress
            )

            guard status == 0 else {
                
                throw AESEncryptionAgentError.generateRandomIVFailed
            }
        }
    }
}

//MARK: - Error

enum AESEncryptionAgentError: Error {
    
    case generateRandomIVFailed
    case encryptionFailed
    case decryptionFailed
    case dataToStringFailed
}
