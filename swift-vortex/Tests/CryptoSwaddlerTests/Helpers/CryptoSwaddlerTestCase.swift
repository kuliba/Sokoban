//
//  CryptoSwaddlerTestCase.swift
//  
//
//  Created by Igor Malyarov on 25.08.2023.
//

import CryptoKit
import ForaCrypto
import TransferPublicKey
import XCTest

class CryptoSwaddlerTestCase: XCTestCase {
    
    // MARK: - Helpers
    
    typealias SecKeySwaddler = PublicRSAKeySwaddler<TestOTP, SecKey, SecKey>
    
    func createRandom4096RSAKeys() throws -> (
        privateKey: SecKey,
        publicKey: SecKey
    ) {
        try Crypto.createRandomSecKeys(
            keyType: .rsa,
            keySize: .bits4096
        )
    }
    
    struct TestOTP {
        
        let value: String
    }
    
    func anyTestOTP(value: String = "abc123") -> TestOTP {
        
        .init(value: value)
    }
    
    func anySharedSecret<OTP>(
        bitCount: Int = 64
    ) -> SwaddleKeyDomain<OTP>.SharedSecret {
        
        .init(anyData(bitCount: bitCount))
    }
    
    func anyData(bitCount: Int = 256) -> Data {
        
        let key = SymmetricKey(size: .init(bitCount: bitCount))
        
        return key.withUnsafeBytes { Data($0) }
    }
}
