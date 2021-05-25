//
//  AES256.swift
//  ForaBank
//
//  Created by Дмитрий on 23.04.2021.
//  Copyright © 2021 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class AES2561{
    
            var error: Unmanaged<CFError>?
            var ownPrivKey: SecKey?
            var publicSecKeyRSA: SecKey?
            var publicKeyBytes: Data?
            let otherKey = "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEF/8gvKPud0r0Lerx4jeDlbGmENWi8gjCga4oQLaFYR6eN9gmQBl9CZ8WU916TKK/Nik+X2TofIEQR6x9kA2H9d0qV4eLP4LUrf0ZSiPxnhRUp2XHBIxILJxqvkusgiVc"
            var bytes: Data?
            var dataEncrypted:Data?
    
            func otherPublicSecKey(data: Data?) -> SecKey? {
               var error: Unmanaged<CFError>? = nil
               let privData1 = Data(base64Encoded: otherKey)
    
               var publicKeyFormatting: SecKey?
               let privRaw2 = privData1?.advanced(by: 23)
    
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
                   publicKeyFormatting = pubKey!
                    bytes = SecKeyCopyExternalRepresentation(pubKey!, &error) as Data?
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
                let newData = Data(bytes: UnsafePointer<UInt8>(encryptedData), count: encryptedData.count).base64EncodedString()
                print(newData)
                dataEncrypted = Data(bytes: UnsafePointer<UInt8>(encryptedData), count: encryptedData.count)
                return Data(bytes: UnsafePointer<UInt8>(encryptedData), count: encryptedData.count)
            }
    
             func decryptWithRSAKey(_ encryptedData: Data, rsaKeyRef: SecKey, padding: SecPadding) -> Data? {
                let blockSize = SecKeyGetBlockSize(rsaKeyRef)
    
                var encryptedDataAsArray = [UInt8](repeating: 0, count: encryptedData.count / MemoryLayout<UInt8>.size)
                (encryptedData as NSData).getBytes(&encryptedDataAsArray, length: encryptedData.count)
    
                var decryptedData = [UInt8](repeating: 0, count: 0)
                var idx = 0
                while (idx < encryptedDataAsArray.count ) {
                    var idxEnd = idx + blockSize
                    if ( idxEnd > encryptedDataAsArray.count ) {
                        idxEnd = encryptedDataAsArray.count
                    }
                    var chunkData = [UInt8](repeating: 0, count: blockSize)
                    for i in idx..<idxEnd {
                        chunkData[i-idx] = encryptedDataAsArray[i]
                    }
    
                    var decryptedDataBuffer = [UInt8](repeating: 0, count: blockSize)
                    var decryptedDataLength = blockSize
    
                    let status = SecKeyDecrypt(rsaKeyRef, padding, chunkData, idxEnd-idx, &decryptedDataBuffer, &decryptedDataLength)
                    if ( status != noErr ) {
                        return nil
                    }
                    let finalData = removePadding(decryptedDataBuffer)
                    decryptedData += finalData
    
                    idx += blockSize
                }
                let newData = Data(bytes: UnsafePointer<UInt8>(decryptedData), count: encryptedData.count).base64EncodedString()
                print(newData)
                return Data(bytes: UnsafePointer<UInt8>(decryptedData), count: decryptedData.count)
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
    
            func publicKey(for certificate: SecCertificate) -> SecKey? {
//                let otherPublicKey = otherPublicSecKey(data:  Data(base64Encoded: otherKey)!)!
                if #available(iOS 12.0, *) {
                    print(SecCertificateCopyKey(certificate))
                    encryptWithRSAKey( Data(base64Encoded: otherKey)!, rsaKeyRef: SecCertificateCopyKey(certificate)!, padding: .PKCS1)
                    decryptWithRSAKey(dataEncrypted!, rsaKeyRef: SecCertificateCopyKey(certificate)!, padding: .PKCS1)
    
                    return SecCertificateCopyKey(certificate)
                } else if #available(iOS 10.3, *) {
                    print(SecCertificateCopyPublicKey(certificate))
                    encryptWithRSAKey( Data(base64Encoded: otherKey)!, rsaKeyRef:  SecCertificateCopyPublicKey(certificate)!, padding: .PKCS1)
                    return SecCertificateCopyPublicKey(certificate)
                } else {
                    var possibleTrust: SecTrust?
                    SecTrustCreateWithCertificates(certificate, SecPolicyCreateBasicX509(), &possibleTrust)
                    guard let trust = possibleTrust else { return nil }
                    var result: SecTrustResultType = .unspecified
                    SecTrustEvaluate(trust, &result)
                    print(SecTrustCopyPublicKey(trust))
                    encryptWithRSAKey( Data(base64Encoded: otherKey)!, rsaKeyRef: SecTrustCopyPublicKey(trust)!, padding: .PKCS1)
    
                    return SecTrustCopyPublicKey(trust)
                }
            }
    
            func encryptedPublicKey() -> SecKey? {
               let pubicKeyPem = "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"
    
    
               let certInDer = Data(base64Encoded: pubicKeyPem)
               let secCert = SecCertificateCreateWithData(nil, certInDer as! CFData) // certInDer is Certificate(.der) data
                       var keychainQueryDictionary = [String : Any]()
    
                       if let tempSecCert = secCert {
                           keychainQueryDictionary = [kSecClass as String : kSecClassCertificate, kSecValueRef as String : tempSecCert, kSecAttrLabel as String: "My Certificate"]
                       }
    
                       let summary = SecCertificateCopySubjectSummary(secCert!)! as String
                       print("Cert summary: \(summary)")
    
                       let status = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
    
    //                    guard status == errSecSuccess else {
    //                       throw print("Error")
    //                    }
    
               publicKey(for: secCert!)
    
               let attributesRSAPub: [String:Any] = [
                   kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                   kSecAttrKeyClass as String: kSecAttrKeyClassPublic
               ]
               print(pubicKeyPem.count)
               let pubKeyRSAData = Data(base64Encoded: pubicKeyPem)
               let publicKeySec = SecKeyCreateWithData(pubKeyRSAData as! CFData, attributesRSAPub as CFDictionary, &error)
    
                return publicKeySec ?? nil
           }
        
}
