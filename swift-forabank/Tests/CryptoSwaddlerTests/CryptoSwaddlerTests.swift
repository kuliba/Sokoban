//
//  CryptoSwaddlerTests.swift
//  
//
//  Created by Igor Malyarov on 25.08.2023.
//

import CryptoSwaddler
import ForaCrypto
import TransferPublicKey
import XCTest

extension OTPEncrypter where PrivateKey == SecKey {
    
    static func signingWithTransportEncryption(
        mapOTP: @escaping (OTP) throws -> Data
    ) -> OTPEncrypter {
        
        .signing(
            mapOTP: mapOTP,
            encryptWithTransportPublicRSAKey: Crypto.transportEncrypt
        )
    }
}

final class CryptoSwaddlerTests: CryptoSwaddlerTestCase {
    
    func test_aesGCMSwaddler_swaddleKey_shouldFailOnShortSecret() throws {
        
        try XCTAssertThrowsError(makeSUT().swaddleKey(
            with: anyTestOTP(),
            and: anySharedSecret(bitCount: 64)
        ))
    }
    
    func test_aesGCMSwaddler_swaddleKey() throws {
        
        let swaddled = try makeSUT().swaddleKey(
            with: anyTestOTP(),
            and: anySharedSecret(bitCount: 128)
        )
        
        XCTAssertFalse(swaddled.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SecKeySwaddler {
        
        let otpEncrypter: SecKeyOTPEncrypter = .signingWithTransportEncryption(
            mapOTP: { $0.value.data(using: .utf8)! }
        )
        let sut: PublicRSAKeySwaddler = .aesGCMSwaddler(
            generateRSA4096BitKeys: createRandom4096RSAKeys,
            otpEncrypter: otpEncrypter,
            saveKeys: { privateKey, publicKey in }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

#warning("copy from `Services+makePublicRSAKeySwaddler.swift:14`")
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

#warning("copy from `Services+transferPublicKeyService.swift:202`")
private extension PublicRSAKeySwaddler
where OTP == CryptoSwaddlerTestCase.TestOTP,
      PrivateKey == SecKey,
      PublicKey == SecKey {
    
    static func aesGCMSwaddler(
        generateRSA4096BitKeys: @escaping GenerateRSA4096BitKeys,
        otpEncrypter: OTPEncrypter<OTP, PrivateKey>,
        saveKeys: @escaping SaveKeys
    ) -> Self {
        
        .init(
            generateRSA4096BitKeys: generateRSA4096BitKeys,
            otpEncrypter: otpEncrypter,
            saveKeys: saveKeys,
            aesEncrypt128bitChunks: { data, secret in
                
                let aesGCMEncryptionAgent = AESGCMEncryptionAgent(data: secret.data)
                return try aesGCMEncryptionAgent.encrypt(data)
            }
        )
    }
    
    convenience init(
        generateRSA4096BitKeys: @escaping GenerateRSA4096BitKeys,
        otpEncrypter: OTPEncrypter<OTP, PrivateKey>,
        saveKeys: @escaping SaveKeys,
        aesEncrypt128bitChunks: @escaping AESEncryptBits128Chunks
    ) {
        self.init(
            generateRSA4096BitKeys: generateRSA4096BitKeys,
            encryptOTPWithRSAKey: otpEncrypter.encrypt,
            saveKeys: saveKeys,
            aesEncrypt128bitChunks: aesEncrypt128bitChunks
        )
    }
    
    private func swaddle(
        otp: OTP,
        sharedSecret: SwaddleKeyDomain<OTP>.SharedSecret,
        completion: @escaping (Result<Data, any Error>) -> Void
    ) {
        completion(
            .init(catching: {
                
                try swaddleKey(with: otp, and: sharedSecret)
            })
        )
    }
}

