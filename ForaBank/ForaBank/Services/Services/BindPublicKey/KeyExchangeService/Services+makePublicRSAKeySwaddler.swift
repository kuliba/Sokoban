//
//  Services+publicRSAKeySwaddler.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.08.2023.
//

import CryptoKit
import CvvPin
import ForaCrypto
import Foundation
import TransferPublicKey

extension SecKey: RawRepresentational {
    
    public var rawRepresentation: Data {
        
        get throws {
            
            var error: Unmanaged<CFError>?
            guard let externalRepresentation = SecKeyCopyExternalRepresentation(self, &error) as? Data
            else {
                throw error!.takeRetainedValue() as Swift.Error
            }
            
            return externalRepresentation
        }
    }
}

struct OTP {
    
    let value: String
}

extension Services {
    
    typealias TransferPublicRSAKeySwaddler = TransferPublicKey.PublicRSAKeySwaddler<OTP, SecKey, SecKey>
    typealias TOTPEncrypter = TransferPublicKey.OTPEncrypter<OTP, SecKey>
    
    static func publicRSAKeySwaddler(
        // try PublicTransportKey.fromCert()
        with transportPublicRSAKey: SecKey,
        //saS: SaS
        symmetricKey: SymmetricKey
    ) throws -> TransferPublicRSAKeySwaddler {
        
        let signWithPadding: TOTPEncrypter.SignWithPadding = { _,_ in
            
            #warning("FIX THIS")
            return unimplemented("EncryptWithPadding")
        }
        
        let encryptWithTransportPublicRSAKey = { data in
            
            try ForaCrypto.Crypto.rsaEncrypt(
                data: data,
                withPublicKey: transportPublicRSAKey,
                algorithm: .rsaEncryptionRaw
            )
        }
        
        let otpEncrypter = TOTPEncrypter(
            signWithPadding: signWithPadding,
            encryptWithTransportPublicRSAKey: encryptWithTransportPublicRSAKey
        )
        
        let saveKeys: TransferPublicRSAKeySwaddler.SaveKeys = { _,_ in
            
            #warning("FIX THIS")
        }
        
        let aesEncrypt128bitChunks: TransferPublicRSAKeySwaddler.AESEncryptBits128Chunks = { data, secret in
            
            // from Encription.encryptAES(string:)
            let salt = AES256.randomSalt()
            let iv = AES256.randomIv()
            #warning("FIX THIS")
            let aes = try AES256(key: unimplemented(), iv: iv)
            
            return try aes.encrypt(data)
        }
        
        return .init(
            generateRSA4096BitKeys: Crypto.createRandomRSA4096BitKeys,
            encryptOTPWithRSAKey: otpEncrypter.encrypt(_:withRSAKey:),
            saveKeys: saveKeys,
            aesEncrypt128bitChunks: aesEncrypt128bitChunks
        )
    }
}

func unimplemented<T>(
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) -> T {
    
    fatalError("Unimplemented: \(message)", file: file, line: line)
}
