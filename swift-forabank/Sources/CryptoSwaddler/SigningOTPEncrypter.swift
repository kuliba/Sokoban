//
//  SigningOTPEncrypter.swift
//  
//
//  Created by Igor Malyarov on 25.08.2023.
//

import ForaCrypto
import Foundation
import TransferPublicKey

extension OTPEncrypter where PrivateKey == SecKey {
    
    public static func signing(
        mapOTP: @escaping (OTP) throws -> Data,
        encryptWithTransportPublicRSAKey: @escaping EncryptWithTransportPublicRSAKey
    ) -> OTPEncrypter {
        
        let encryptWithPadding: EncryptWithPadding = { otp, privateKey in
            
            try Crypto.sign(
                mapOTP(otp),
                withPrivateKey: privateKey,
                algorithm: .rsaSignatureRaw
            )
        }
        
        return .init(
            encryptWithPadding: encryptWithPadding,
            encryptWithTransportPublicRSAKey: encryptWithTransportPublicRSAKey
        )
    }
}


