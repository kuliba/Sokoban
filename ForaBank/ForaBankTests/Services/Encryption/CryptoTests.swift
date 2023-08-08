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
        
        let secKey = try publicSecKey()
        let data = try XCTUnwrap("some data".data(using: .utf8))
        
        let encrypted = try Crypto.rsaPKCS1Encrypt(data: data, withPublicKey: secKey)
        
        XCTAssertNotEqual(encrypted, data)
    }
    
    // MARK: - Helpers Tests
    
    func test_publicSecKey_shouldBeOkForRSAEncryptionPKCS1() throws {
        
        let secKey = try publicSecKey()
        let rsaEncryptionPKCS1 = SecKeyIsAlgorithmSupported(secKey, .encrypt, .rsaEncryptionPKCS1)
        
        XCTAssertTrue(rsaEncryptionPKCS1)
    }
    
    // MARK: Helpers
    
    private func publicSecKey() throws -> SecKey {
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String:
                [kSecAttrIsPermanent as String: false]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey)
        else {
            throw error!.takeRetainedValue() as Error
        }
        
        return publicKey
    }
    
    private func keyData() throws -> Data {
        
        let keyBase64 = "MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEFZp5pRhs5snqQLa5AsGGtPKvaFfxF3CgSDMKCmwCAKmeZtKetmdUAq/UrfFjP7k7rbH+QSLisR/g3XHFVwQY/CSbuqII5i5Adh2ssCtYmQ7oDbvmk9PbeyCZE4twlNtV"
        
        return try XCTUnwrap(Data(base64Encoded: keyBase64))
    }
}
