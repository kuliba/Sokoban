//
//  AESGCMEncryptionAgentTests.swift
//  
//
//  Created by Igor Malyarov on 24.08.2023.
//

import CryptoKit
import ForaCrypto
import XCTest

final class AESGCMEncryptionAgentTests: XCTestCase {
    
    func test_encrypt_decrypt_shouldFailOn48() throws {
        
        let sut = AESGCMEncryptionAgent(bitCount: 48)
        
        try XCTAssertThrowsError(sut.encrypt(anyData()))
    }
    
    func test_encrypt_decrypt_128() throws {
        
        let message = "important message"
        let data = try XCTUnwrap(message.data(using: .utf8))
        let sut = AESGCMEncryptionAgent(bitCount: 128)
        
        let encrypted = try sut.encrypt(data)
        let decrypted = try sut.decrypt(encrypted)
        
        XCTAssertNotEqual(encrypted, decrypted)
        
        let decryptedMessage = String(data: decrypted, encoding: .utf8)
        XCTAssertEqual(decryptedMessage, message)
    }
    
    func test_encrypt_decrypt_256() throws {
        
        let message = "important message"
        let data = try XCTUnwrap(message.data(using: .utf8))
        let sut = AESGCMEncryptionAgent(bitCount: 256)
        
        let encrypted = try sut.encrypt(data)
        let decrypted = try sut.decrypt(encrypted)
        
        XCTAssertNotEqual(encrypted, decrypted)
        
        let decryptedMessage = String(data: decrypted, encoding: .utf8)
        XCTAssertEqual(decryptedMessage, message)
    }
    
    func test_encrypt_decrypt_shouldFailOn384() throws {
        
        let sut = AESGCMEncryptionAgent(bitCount: 384)
        
        try XCTAssertThrowsError(sut.encrypt(anyData()))
    }
    
    func test_initFromData_encrypt_decrypt() throws {
        
        let message = "important message"
        let data = try XCTUnwrap(message.data(using: .utf8))
        let keyData = anyData()
        let sut = AESGCMEncryptionAgent(data: keyData)
        
        let encrypted = try sut.encrypt(data)
        let decrypted = try sut.decrypt(encrypted)
        
        XCTAssertNotEqual(encrypted, decrypted)
        
        let decryptedMessage = String(data: decrypted, encoding: .utf8)
        XCTAssertEqual(decryptedMessage, message)
    }
    
    // MARK: - Helpers
    
    private func anyData(bitCount: Int = 256) -> Data {
        
        let key = SymmetricKey(size: .init(bitCount: bitCount))
        
        return key.withUnsafeBytes { Data($0) }
    }
}
