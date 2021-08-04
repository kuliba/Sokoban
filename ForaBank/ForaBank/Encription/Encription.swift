//
//  Encription.swift
//  ForaBank
//
//  Created by Дмитрий on 11.06.2021.
//

import Foundation
//import CryptoSwift
import CommonCrypto


struct KeyPair {
    static var publicKey: SecKey?
    static var privateKey: SecKey?
}

struct KeyFromServer {
    static var publicKey: String?
    static var publicKeyCert: String?
    static var privateKeyCert: String?
    static var pubFromServ: SecKey?
    static var secretKey: Data?
    static var sendBase64ToServ: String?
    static var secretKeyString: String?
}

class Encription {
    
    var pubFromCert: SecKey?
    var pubFromServ: SecKey?
    var sendBase64ToServ: String?
    var error: Unmanaged<CFError>?
    var secretKey: Data?
    
    func createOwnKey() -> SecKey? {
        
        var publicKeySec, privateKeySec: SecKey?
        let keyattribute = [kSecAttrKeySizeInBits as String: 384,
                            SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32,
                            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                            
                            kSecPrivateKeyAttrs as String: [kSecAttrIsPermanent as String: false],
                            kSecPublicKeyAttrs as String:[kSecAttrIsPermanent as String: false]] as [String : Any]
        
        SecKeyGeneratePair(keyattribute as CFDictionary, &publicKeySec, &privateKeySec)
//        addPemToKey(publicKeySec: publicKeySec!)
//        addPemToKey(publicKeySec: privateKeySec!)
        KeyPair.privateKey = privateKeySec
        KeyPair.publicKey = publicKeySec
        return privateKeySec
    }
    
    func otherPublicSecKey(data: Data?) -> SecKey? {
           var error: Unmanaged<CFError>? = nil
    //    let privData1 = Data(base64Encoded: data!)

           
           let privRaw2 = data?.advanced(by: 23)

           return privRaw2?.withUnsafeBytes { (unsafeBytes) -> SecKey? in
              let bytes2 =  unsafeBytes.baseAddress?.advanced(by: 0).bindMemory(to: UInt8.self, capacity: 0)
               let CFPrivData1 = CFDataCreate(nil, bytes2, unsafeBytes.count - 0)
               print(unsafeBytes.count)
               let attributes =  [
                   kSecAttrKeySizeInBits: 384,
                      kSecAttrKeyType: kSecAttrKeyTypeEC,
                       SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32,
                      kSecAttrKeyClass: kSecAttrKeyClassPublic,
                  ] as CFDictionary

               let pubKey = SecKeyCreateWithData(CFPrivData1!, attributes as CFDictionary, &error)
               pubFromServ = pubKey!
            KeyFromServer.pubFromServ = pubKey
//                bytes = SecKeyCopyExternalRepresentation(pubKey!, &error) as Data?
               if let publicKey = SecKeyCreateWithData(CFPrivData1!, attributes, &error) {
                   return publicKey
               } else {
                   print("other EC public: (String(describing: error))")
                   return nil
               }
           }
       }
       func encryptWithRSAKey(_ data: Data, rsaKeyRef: SecKey, padding: SecPadding) -> Data? {
            let blockSize = SecKeyGetBlockSize(rsaKeyRef)
            let maxChunkSize = blockSize - 11

            var decryptedDataAsArray = [UInt8](repeating: 0, count: data.count / MemoryLayout<UInt8>.size)
            (data as NSData).getBytes(&decryptedDataAsArray, length: data.count)

            var encryptedData = [UInt8](repeating: 0, count: 0)
            var idx = 0
            while (idx < decryptedDataAsArray.count ) {
                var idxEnd = idx + maxChunkSize
                if ( idxEnd > decryptedDataAsArray.count ) {
                    idxEnd = decryptedDataAsArray.count
                }
                var chunkData = [UInt8](repeating: 0, count: maxChunkSize)
                for i in idx..<idxEnd {
                    chunkData[i-idx] = decryptedDataAsArray[i]
                }

                var encryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
                var encryptedDataLength = blockSize

                let status = SecKeyEncrypt(rsaKeyRef, padding, chunkData, idxEnd-idx, &encryptedDataBuffer, &encryptedDataLength)
                if ( status != noErr ) {
                    NSLog("Error while ecrypting: %i", status)
                    return nil
                }
                //let finalData = removePadding(encryptedDataBuffer)
                encryptedData += encryptedDataBuffer


                idx += maxChunkSize
            }

            return Data(bytes: UnsafePointer<UInt8>(encryptedData), count: encryptedData.count)
        }

        func encryptAES(string: String) -> String?{
    
            do {
    
                let digest = string.data(using: .utf8)!
                let salt = AES256.randomSalt()
    
                let iv = AES256.randomIv()
                print("Randomize\(iv)")
    
                guard let key = KeyFromServer.secretKey else {
                    return nil
                }
                print(key)
    
                let aes = try AES256(key: key, iv: iv)
    
                let encrypted = try aes.encrypt(digest)
                let decrypted = try aes.decrypt(encrypted)
    
                print("Encrypted: \(encrypted.hexadecimal)")
                print("Decrypted: \(decrypted)")
    
                let string1 = encrypted.base64EncodedString()
                print(string1)
    
//                let data: Data = decrypted
//                if let string = String(data: string1, encoding: .utf8) {
//                    print(string)
//                } else {
//                    print("not a valid UTF-8 sequence")
//                }

                
                return encrypted.base64EncodedString()
            } catch {
                print("Failed")
                print(error)
                }
            return nil
        }

    func removePadding(_ data: [UInt8]) -> [UInt8] {
           var idxFirstZero = -1
           var idxNextZero = data.count
           for i in 0..<data.count {
               if ( data[i] == 0 ) {
                   if ( idxFirstZero < 0 ) {
                       idxFirstZero = i
                   } else {
                       idxNextZero = i
                       break
                   }
               }
           }
           var newData = [UInt8](repeating: 0, count: idxNextZero-idxFirstZero-1)
           for i in idxFirstZero+1..<idxNextZero {
               newData[i-idxFirstZero-1] = data[i]
           }
           return newData
       }

        func addPemToKey(publicKeySec: SecKey) -> Data{
                
                let fullKeyData = CFDataCreateMutable(kCFAllocatorDefault, CFIndex(0))
                if fullKeyData != nil {
                    //Fixed schema header per key size in bits
    //                var headerBytes256r1: [UInt8] = [0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00] //uncomment if you use 256 bit EC keys
                    var header384r1: [UInt8] = [0x30, 0x76, 0x30, 0x10, 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, 0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00] //384 bit EC keys
                    //var header521r1: [UInt8] = [0x30, 0x81, 0x9B, 0x30, 0x10, 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D, 0x02, 0x01, 0x06, 0x05, 0x2B, 0x81, 0x04, 0x00, 0x23, 0x03, 0x81, 0x86, 0x00] // For 521 bit EC keys
                    let headerSize = CFIndex(header384r1.count)
                    let cfdata = SecKeyCopyExternalRepresentation(publicKeySec, &error)

                    CFDataAppendBytes(fullKeyData, &header384r1, headerSize)
                    CFDataAppendBytes(fullKeyData, CFDataGetBytePtr(cfdata), CFDataGetLength(cfdata)) //pub = data you got from SecKeyCopyExternalRepresentation

                    var pem = ""
                    //pem.append("-----BEGIN PUBLIC KEY-----\n") //uncomment if needed
                    pem.append((fullKeyData as Data?)?.base64EncodedString() ?? "")
                    print((fullKeyData as Data?)?.base64EncodedString() ?? "")
                    
                    //pem.append("\n-----END PUBLIC KEY-----\n") //uncomment if needed

                    //do something with pem
                    return fullKeyData! as Data
                }
            return fullKeyData! as Data
            }
        
        func encodingSecKey(data : SecKey){
            if let cfdata = SecKeyCopyExternalRepresentation(data, &error){
               let data:Data = cfdata as Data
               let b64Key = data.base64EncodedString()
                print(b64Key)
            }
        }
        
    func publicKey(for certificate: SecCertificate) -> SecKey? {
                createOwnKey()
                pubFromCert = SecCertificateCopyKey(certificate)
                let str = KeyFromServer.publicKey!
                let lastKey: CFData?
                let keyWithPem = addPemToKey(publicKeySec: KeyPair.publicKey!)

        lastKey = SecKeyCreateDecryptedData(pubFromCert!, .rsaEncryptionRaw,  Data(base64Encoded: str)! as CFData, &error)
        let newData = SecKeyCreateEncryptedData(pubFromCert!, .rsaEncryptionPKCS1, keyWithPem as CFData, &error)
            sendBase64ToServ = (newData as Data?)?.base64EncodedString()
                let data = (lastKey as Data?)?.advanced(by: 136)
            KeyFromServer.sendBase64ToServ = sendBase64ToServ
                otherPublicSecKey(data: data)

                return SecCertificateCopyKey(certificate)
            
    }


    func encryptedPublicKey() -> SecKey? {
        
        let pubicKeyPem = KeyFromServer.publicKeyCert

        let certInDer = Data(base64Encoded: pubicKeyPem!, options: .ignoreUnknownCharacters)
        let secCert = SecCertificateCreateWithData(nil, certInDer! as CFData) // certInDer is Certificate(.der) data

            return  publicKey(for: secCert!)
       }
        
        func computeSharedSecret(ownPrivateKey: SecKey, otherPublicKey: SecKey) -> Data? {
           let algorithm:SecKeyAlgorithm = SecKeyAlgorithm.ecdhKeyExchangeStandard
           let params = [SecKeyKeyExchangeParameter.requestedSize.rawValue: 32, SecKeyKeyExchangeParameter.sharedInfo.rawValue: Data()] as [String: Any]
           
           var error: Unmanaged<CFError>? = nil
           print(otherPublicKey)
            if let sharedSecret: Data = SecKeyCopyKeyExchangeResult(ownPrivateKey, algorithm, otherPublicKey, params as CFDictionary, &error) as Data? {
                
        
                secretKey = Data(base64Encoded: sharedSecret.base64EncodedString())?.dropLast(16)
//                KeyFromServer.secretKeyString =
                KeyFromServer.secretKey =  Data(base64Encoded: sharedSecret.base64EncodedString())?.dropLast(16)
               SecKeyCopyExternalRepresentation(ownPrivateKey, &error)
                
               return sharedSecret
           } else {
               print("key exchange: (String(describing: error))")
           }
           return nil
        }
}

protocol Cryptable {
    func encrypt(_ string: String) throws -> Data
    func decrypt(_ data: Data) throws -> String
}

struct AES {
    private let key: Data
    private let ivSize: Int         = kCCBlockSizeAES128
    private let options: CCOptions  = CCOptions(kCCOptionPKCS7Padding)

    init(keyString: Data) throws {
        self.key = keyString
        
    }
}

extension AES {
    enum Error: Swift.Error {
        case generateRandomIVFailed
        case encryptionFailed
        case decryptionFailed
        case dataToStringFailed
    }
}

private extension AES {

    func generateRandomIV(for data: inout Data) throws {

        try data.withUnsafeMutableBytes { dataBytes in

            guard let dataBytesBaseAddress = dataBytes.baseAddress else {
                throw Error.generateRandomIVFailed
            }

            let status: Int32 = SecRandomCopyBytes(
                kSecRandomDefault,
                kCCBlockSizeAES128,
                dataBytesBaseAddress
            )

            guard status == 0 else {
                throw Error.generateRandomIVFailed
            }
        }
    }
}

extension AES: Cryptable {

    func encrypt(_ string: String) throws -> Data {
        let dataToEncrypt = Data(string.utf8)

        let bufferSize: Int = ivSize + dataToEncrypt.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        try generateRandomIV(for: &buffer)

        var numberBytesEncrypted: Int = 0

        do {
            try key.withUnsafeBytes { keyBytes in
                try dataToEncrypt.withUnsafeBytes { dataToEncryptBytes in
                    try buffer.withUnsafeMutableBytes { bufferBytes in

                        guard let keyBytesBaseAddress = keyBytes.baseAddress,
                            let dataToEncryptBytesBaseAddress = dataToEncryptBytes.baseAddress,
                            let bufferBytesBaseAddress = bufferBytes.baseAddress else {
                                throw Error.encryptionFailed
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
                            throw Error.encryptionFailed
                        }
                    }
                }
            }

        } catch {
            throw Error.encryptionFailed
        }

        let encryptedData: Data = buffer[..<(numberBytesEncrypted + ivSize)]
        return encryptedData
    }

    func decrypt(_ data: Data) throws -> String {
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
                                throw Error.encryptionFailed
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
                            throw Error.decryptionFailed
                        }
                    }
                }
            }
        } catch {
            throw Error.encryptionFailed
        }

        let decryptedData: Data = buffer[..<numberBytesDecrypted]
        let decryptedMyData = buffer.prefix(16)
        let newString = decryptedMyData.base64EncodedString()
        print(newString.base64Decoded())
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw Error.dataToStringFailed
        }
        

        return decryptedString
    }
}

