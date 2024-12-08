//
//  AES256CBCTests.swift
//  
//
//  Created by Igor Malyarov on 23.08.2023.
//

import CryptoKit
import VortexCrypto
import XCTest

final class AES256CBCTests: XCTestCase {
    
    func test_AES256CBC() throws {
        
        let password = AES256CBC.randomData(length: 256)
        let publicKeyData = try AES256CBC.createKey(password: password)
        
        let aes256 = try AES256CBC(key: publicKeyData)
        
        let otp = "abc123"
        let otpData = try XCTUnwrap(otp.data(using: .utf8))
        let encrypted = try aes256.encrypt(otpData)
        
        let decrypted = try aes256.decrypt(encrypted)
        
        XCTAssertEqual(decrypted.count, 6)
        XCTAssertEqual(String(data: decrypted, encoding: .utf8), otp)
    }
}
