//
//  OTPEncrypter.swift
//  
//
//  Created by Igor Malyarov on 07.08.2023.
//

import Foundation

public final class OTPEncrypter<PrivateKey> {
    
    public typealias EncryptWithPadding = (String, PrivateKey) throws -> Data
    public typealias EncryptWithTransportPublicRSAKey = (Data) throws -> Data
    
    private let encryptWithPadding: EncryptWithPadding
    private let encryptWithTransportPublicRSAKey: EncryptWithTransportPublicRSAKey
    
    public init(
        encryptWithPadding: @escaping EncryptWithPadding,
        encryptWithTransportPublicRSAKey: @escaping EncryptWithTransportPublicRSAKey
    ) {
        self.encryptWithPadding = encryptWithPadding
        self.encryptWithTransportPublicRSAKey = encryptWithTransportPublicRSAKey
    }
    
    public func encrypt(
        _ otp: OTP,
        withRSAKey privateKey: PrivateKey
    ) throws -> Data {
        
        let clientSecretOTP = try encryptWithPadding(otp.value, privateKey)
        let procClientSecretOTP = try encryptWithTransportPublicRSAKey(clientSecretOTP)
        
        return procClientSecretOTP
    }
}
