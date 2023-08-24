//
//  CryptoTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.08.2023.
//

@testable import ForaBank
import XCTest

final class CryptoTests: XCTestCase {
    
    func test_rsaPKCS1Encrypt_shouldEncryptData() throws {
        
        let publicKey = try makeSecKeyPair().publicKey
        let data = try XCTUnwrap("some data".data(using: .utf8))
        
        let encrypted = try Crypto.rsaPKCS1Encrypt(data: data, withPublicKey: publicKey)
        
        XCTAssertNotEqual(encrypted, data)
    }
    
    func test_rsaPKCS1Decrypt_shouldDecryptEncryptedData() throws {
        
        let originalMessage = "some data"
        let data = try XCTUnwrap(originalMessage.data(using: .utf8))
        let (privateKey, publicKey) = try makeSecKeyPair()
        
        let encrypted = try Crypto.rsaPKCS1Encrypt(data: data, withPublicKey: publicKey)
        let decrypted = try Crypto.rsaPKCS1Decrypt(data: encrypted, withPrivateKey: privateKey)
        let decryptedMessage = try XCTUnwrap(String(data: decrypted, encoding: .utf8))
        
        XCTAssertNoDiff(originalMessage, decryptedMessage)
    }
    
    // MARK: - Helpers Tests
    
    func test_makeSecKeyPair_shouldCreatePublicKeyForRSAEncryptionPKCS1() throws {
        
        let publicKey = try makeSecKeyPair().publicKey
        let rsaEncryptionPKCS1 = SecKeyIsAlgorithmSupported(publicKey, .encrypt, .rsaEncryptionPKCS1)
        
        XCTAssertTrue(rsaEncryptionPKCS1)
    }
    
    // MARK: - Helpers
    
    private func makeSecKeyPair() throws -> (
        privateKey: SecKey,
        publicKey: SecKey
    ) {
        return try Crypto.createRandomRSA4096BitKeys()
    }
    
    private func keyData() throws -> Data {
        
        let keyBase64 = "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFZp5pRhs5snqQLa5AsGGtPKvaFfxF3CgSDMKCmwCAKmeZtKetmdUAq/UrfFjP7k7rbH+QSLisR/g3XHFVwQY/CSbuqII5i5Adh2ssCtYmQ7oDbvmk9PbeyCZE4twlNtV"
        
        return try XCTUnwrap(Data(base64Encoded: keyBase64))
    }
}
