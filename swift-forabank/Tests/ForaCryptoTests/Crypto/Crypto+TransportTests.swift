//
//  Crypto+TransportTests.swift
//  
//
//  Created by Igor Malyarov on 04.09.2023.
//

import ForaCrypto
import XCTest

final class Crypto_TransportTests: XCTestCase {
    
    func test_transportEncrypt() throws {
        
        let data = Data("very very important message".utf8)
        let encrypted = try Crypto.transportEncrypt(data)
        
        XCTAssertEqual(encrypted.count, 512)
    }
    
    func test_transportPublicKey_length() throws {
        
        try XCTAssertEqual(
            transportPublicKey().rawRepresentation().count,
            526
        )
    }
    
    // MARK: - Helpers
    
    private func transportPublicKey() throws -> SecKey {
        
        try Crypto.transportKey()
    }
}
