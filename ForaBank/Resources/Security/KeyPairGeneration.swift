//
//  KeyPairGeneration.swift
//  ForaBank
//
//  Created by Дмитрий on 30.04.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import CryptoKit

class KeyPairGeneration{
    
    var error: Unmanaged<CFError>?
    var publicKeySec, privateKeySec: SecKey?

    
    
    func createOwnKey() -> SecKey? {
        
        var publicKeySec, privateKeySec: SecKey?
        let keyattribute = [kSecAttrKeySizeInBits as String: 384,
                            SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32,
                            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                            
                            kSecPrivateKeyAttrs as String: [kSecAttrIsPermanent as String: false],
                            kSecPublicKeyAttrs as String:[kSecAttrIsPermanent as String: false]] as [String : Any]
        
        SecKeyGeneratePair(keyattribute as CFDictionary, &publicKeySec, &privateKeySec)
        addPemToKey(publicKeySec: publicKeySec!)
        addPemToKey(publicKeySec: privateKeySec!)
        KeyPair.privateKey = privateKeySec
        KeyPair.publicKey = publicKeySec
        return privateKeySec
    }
    
    func addPemToKey(publicKeySec: SecKey){
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
            }
        }
    
    func otherPublicSecKey(string: String) -> SecKey? {
       var error: Unmanaged<CFError>? = nil
       
        let privData1 = Data(base64Encoded: string, options: [.ignoreUnknownCharacters])
        
//        let pubKeyData = string.data(using: .ascii)
                
       var publicKeyFormatting: SecKey?
       let privRaw = privData1?.advanced(by: 0)

       return privRaw?.withUnsafeBytes { (unsafeBytes) -> SecKey? in
          let bytes =  unsafeBytes.baseAddress?.advanced(by: 0).bindMemory(to: UInt8.self, capacity: 0)
           let CFPrivData = CFDataCreate(nil, bytes, unsafeBytes.count - 0)
           print(unsafeBytes.count)

           let attributes =  [
               kSecAttrKeySizeInBits: 384,
                  kSecAttrKeyType: kSecAttrKeyTypeEC,
                   SecKeyKeyExchangeParameter.requestedSize.rawValue as String: 32,
                  kSecAttrKeyClass: kSecAttrKeyClassPublic,
              ] as CFDictionary

           let pubKey = SecKeyCreateWithData(CFPrivData!, attributes as CFDictionary, &error)
//        let pubKeyFromServer = SecKeyCreateWithData(pubKeyData as! CFData, attributes as CFDictionary, &error)

           publicKeyFormatting = pubKey!
        computeSharedSecret(ownPrivateKey: KeyPair.privateKey!, otherPublicKey: pubKey!)
           if let publicKey = SecKeyCreateWithData(CFPrivData!, attributes, &error) {
               return publicKey
           } else {
               print("other EC public: (String(describing: error))")
               return nil
           }
       }
   }
    
    private func computeSharedSecret(ownPrivateKey: SecKey, otherPublicKey: SecKey) -> Data? {
        let algorithm:SecKeyAlgorithm = SecKeyAlgorithm.ecdhKeyExchangeStandard
        let params = [SecKeyKeyExchangeParameter.requestedSize.rawValue: 32, SecKeyKeyExchangeParameter.sharedInfo.rawValue: Data()] as [String: Any]
        if let sharedSecret: Data = SecKeyCopyKeyExchangeResult(privateKeySec!, algorithm, otherPublicKey, params as CFDictionary, &error) as Data? {
            sharedSecret.base64EncodedString()
            let bytes = sharedSecret.hexadecimal
            Data(base64Encoded: sharedSecret.base64EncodedString())?.dropLast(16)
            let data = bytes.prefix(64)
            Data(base64Encoded: bytes)
            sharedSecret.withUnsafeBytes { (unsafeBytes) -> String in
                print(unsafeBytes)
                return ""
            }
            SecKeyCopyExternalRepresentation(privateKeySec!, &error)
//            let buf = Array(arrayLiteral: sharedSecret.hexadecimal)

            return sharedSecret
        } else {
            print("key exchange: (String(describing: error))")
        }
        return nil
    }
    
}
extension String {
//: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }

//: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
