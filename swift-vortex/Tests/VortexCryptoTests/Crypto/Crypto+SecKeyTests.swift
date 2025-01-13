//
//  Crypto+SecKeyTests.swift
//  
//
//  Created by Igor Malyarov on 14.10.2023.
//

import VortexCrypto
import XCTest

final class Crypto_SecKeyTests: XCTestCase {
    
    func test_crypto_rsa() throws {
        
        let keyType: Crypto.KeyType = .rsa
        let keySizes: [Crypto.KeySize] = [.bits1024, .bits2048, .bits4096]
        
        for keySize in keySizes {
            
            let keyPair = try Crypto.createRandomSecKeys(
                keyType: keyType,
                keySize: keySize
            )
            
            let publicKeyData = try keyPair.publicKey.rawRepresentation()
            let privateKeyData = try keyPair.privateKey.rawRepresentation()
            
            let publicKey = try Crypto.createSecKey(
                from: publicKeyData,
                keyType: keyType,
                keyClass: .publicKey,
                keySize: keySize
            )
            let privateKey = try Crypto.createSecKey(
                from: privateKeyData,
                keyType: keyType,
                keyClass: .privateKey,
                keySize: keySize
            )
            
            let derivedPublicKey = try XCTUnwrap(SecKeyCopyPublicKey(privateKey))
            
            try XCTAssertEqual(
                publicKeyData,
                publicKey.rawRepresentation()
            )
            try XCTAssertEqual(
                privateKeyData,
                privateKey.rawRepresentation()
            )
            try XCTAssertEqual(
                derivedPublicKey.rawRepresentation(),
                publicKey.rawRepresentation()
            )
        }
    }
    
    func test_createPrivateSecKeyWith_shouldThrowOnNonKeyData_kSecAttrKeyClassPrivate() throws {
        
        let nonKeyData = Data("non key".utf8)
        
        try XCTAssertThrowsError(
            Crypto.createSecKey(
                from: nonKeyData,
                keyType: .rsa,
                keyClass: .privateKey,
                keySize: .bits2048
            )
        ) {
            switch $0 {
            case let Crypto.Error.secKeyCreationWithDataFailure(bits, keyType, keyClass, _):
                XCTAssertNoDiff(keyType, kSecAttrKeyTypeRSA)
                XCTAssertNoDiff(keyClass, kSecAttrKeyClassPrivate)
                XCTAssertNoDiff(bits, 2_048)
                
            default:
                XCTFail()
            }
        }
    }
    
    func test_createPrivateSecKeyWith_shouldThrowOnNonKeyData_kSecAttrKeyClassPublic() throws {
        
        let nonKeyData = Data("non key".utf8)
        
        try XCTAssertThrowsError(
            Crypto.createSecKey(
                from: nonKeyData,
                keyType: .rsa,
                keyClass: .publicKey,
                keySize: .bits2048
            )
        ) {
            switch $0 {
            case let Crypto.Error.secKeyCreationWithDataFailure(bits, keyType, keyClass, _):
                XCTAssertNoDiff(keyType, kSecAttrKeyTypeRSA)
                XCTAssertNoDiff(keyClass, kSecAttrKeyClassPublic)
                XCTAssertNoDiff(bits, 2_048)
                
            default:
                XCTFail()
            }
        }
    }
}
