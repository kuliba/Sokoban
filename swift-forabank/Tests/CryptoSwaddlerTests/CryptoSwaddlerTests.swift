//
//  CryptoSwaddlerTests.swift
//  
//
//  Created by Igor Malyarov on 25.08.2023.
//

import CryptoSwaddler
import VortexCrypto
import TransferPublicKey
import XCTest

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
        
        let signWithPadding: (TestOTP, SecKey) throws -> Data = { otp, privateKey in
            
            let data = Data(otp.value.utf8)
            
            return try Crypto.transportEncrypt(data)
        }
        
        let sut: PublicRSAKeySwaddler = .aesGCMSwaddler(
            generateRSA4096BitKeys: createRandom4096RSAKeys,
            signWithPadding: signWithPadding,
            saveKeys: { privateKey, publicKey in }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

#warning("copy from `Services+makePublicRSAKeySwaddler.swift:14`")
extension SecKey {
    
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
    
    typealias SignWithPadding = (OTP, PrivateKey) throws -> Data
    
    static func aesGCMSwaddler(
        generateRSA4096BitKeys: @escaping GenerateRSA4096BitKeys,
        signWithPadding: @escaping SignWithPadding,
        saveKeys: @escaping SaveKeys
    ) -> Self {
        
        .init(
            generateRSA4096BitKeys: generateRSA4096BitKeys,
            signEncryptOTP: signWithPadding,
            saveKeys: saveKeys,
            x509Representation: VortexCrypto.Crypto.x509Representation(of:),
            aesEncrypt128bitChunks: { data, secret in
                
                let aesGCMEncryptionAgent = AESGCMEncryptionAgent(data: secret.data)
                return try aesGCMEncryptionAgent.encrypt(data)
            }
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

