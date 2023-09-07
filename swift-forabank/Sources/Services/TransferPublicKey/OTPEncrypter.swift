//
//  OTPEncrypter.swift
//  
//
//  Created by Igor Malyarov on 07.08.2023.
//

import Foundation

public final class OTPEncrypter<OTP, PrivateKey> {
    
    public typealias SignWithPadding = (OTP, PrivateKey) throws -> Data
    public typealias EncryptWithTransportPublicRSAKey = (Data) throws -> Data
    
    private let signWithPadding: SignWithPadding
    private let encryptWithTransportPublicRSAKey: EncryptWithTransportPublicRSAKey
    
    public init(
        signWithPadding: @escaping SignWithPadding,
        encryptWithTransportPublicRSAKey: @escaping EncryptWithTransportPublicRSAKey
    ) {
        self.signWithPadding = signWithPadding
        self.encryptWithTransportPublicRSAKey = encryptWithTransportPublicRSAKey
    }
    
    public func encrypt(
        _ otp: OTP,
        withRSAKey privateKey: PrivateKey
    ) throws -> Data {
        
        let clientSecretOTP = try signWithPadding(otp, privateKey)
        let procClientSecretOTP = try encryptWithTransportPublicRSAKey(clientSecretOTP)
        
        return procClientSecretOTP
    }
}
