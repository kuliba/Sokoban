//
//  SigningOTPEncrypterTests.swift
//  
//
//  Created by Igor Malyarov on 25.08.2023.
//

import CryptoSwaddler
import VortexCrypto
import TransferPublicKey
import XCTest

final class SigningOTPEncrypterTests: CryptoSwaddlerTestCase {
    
    func test_signingWithNoTransportEncryption() throws {
        
        let (privateKey, publicKey) = try createRandom4096RSAKeys()
        
        let encrypted = try signEncryptOTP()(
            anyTestOTP(),
            privateKey
        )
        
        let signature = try Crypto.createSignature(
            for: encrypted,
            usingPrivateKey: privateKey
        )
        let isVerified = try Crypto.verify(
            encrypted,
            withPublicKey: publicKey,
            signature: signature
        )
        XCTAssertTrue(isVerified)
    }
    
    func test_signingWithTransportEncryption() throws {
        
        let (privateKey, _) = try createRandom4096RSAKeys()
        
        XCTAssertNoThrow(
            try signEncryptOTP()(
                anyTestOTP(),
                privateKey
            )
        )
    }
    
    // MARK: - Helpers
    
    private func signEncryptOTP(
        encryptWithTransportPublicRSAKey: @escaping (Data) throws -> Data = { $0 },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (TestOTP, SecKey) throws -> Data {
        
        return { otp, privateKey in
            
            try encryptWithTransportPublicRSAKey(
                .init(otp.value.utf8)
            )
        }
    }
}
