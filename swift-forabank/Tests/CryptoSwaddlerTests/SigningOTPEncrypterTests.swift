//
//  SigningOTPEncrypterTests.swift
//  
//
//  Created by Igor Malyarov on 25.08.2023.
//

import CryptoSwaddler
import ForaCrypto
import TransferPublicKey
import XCTest

final class SigningOTPEncrypterTests: CryptoSwaddlerTestCase {
    
    func test_signingWithNoTransportEncryption() throws {
        
        let (privateKey, publicKey) = try createRandom4096RSAKeys()
        let sut = makeSUT()
        
        let encrypted = try sut.encrypt(
            anyTestOTP(),
            withRSAKey: privateKey
        )
        
        let signature = try Crypto.createSignature(
            for: encrypted,
            usingPrivateKey: privateKey
        )
        let isVerified = try Crypto.veryfy(
            encrypted,
            withPublicKey: publicKey,
            signature: signature
        )
        XCTAssertTrue(isVerified)
    }
    
    func test_signingWithTransportEncryption() throws {
        
        let (privateKey, _) = try createRandom4096RSAKeys()
        let sut = makeSUT(encryptWithTransportPublicRSAKey: Crypto.transportEncrypt)
        
        XCTAssertNoThrow(
            try sut.encrypt(
                anyTestOTP(),
                withRSAKey: privateKey
            )
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        encryptWithTransportPublicRSAKey: @escaping SecKeyOTPEncrypter.EncryptWithTransportPublicRSAKey = { $0 },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SecKeyOTPEncrypter {
        
        let sut: SecKeyOTPEncrypter = .signing(
            mapOTP: { $0.value.data(using: .utf8)! },
            encryptWithTransportPublicRSAKey: encryptWithTransportPublicRSAKey
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
