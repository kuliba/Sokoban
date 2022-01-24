//
//  ECEncryptionTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 21.01.2022.
//

import XCTest
@testable import ForaBank

class ECEncryptionTests: XCTestCase {
    
    let provider = ECKeysProvider()

    override func tearDownWithError() throws {
        
        try provider.deletePrivateKey()
    }

    func testPublicKey() throws {

        // given
        let publicKeyData = try provider.publicKeyData()
        
        // when
        let publicKeyDataString = publicKeyData.base64EncodedString(options: .endLineWithLineFeed)
        let publicKeyDataFromString = Data(base64Encoded: publicKeyDataString)!
        
        // then
        XCTAssertNoThrow(try provider.publicKey(from: publicKeyDataFromString))
    }
    
    func testEncrypt_Decrypt() throws {
        
        // given
        let sampleString = UUID().uuidString
        let sampleData = sampleString.data(using: .utf8)!
        let publicKey = try provider.getPublicKey()
        let encryptor = Encryptor(publicKey: publicKey, algorithm: provider.algorithm)
        let privateKey = try provider.getPrivateKey()
        let decryptor = Decryptor(privateKey: privateKey, algorithm: provider.algorithm)
        
        // when
        let encrypted = try encryptor.encrypt(sampleData)
        let decrypted = try decryptor.decrypt(encrypted)
        let decryptedString = String(data: decrypted, encoding: .utf8)
        
        // then
        XCTAssertNotNil(decryptedString)
        XCTAssertEqual(decryptedString!, sampleString)
    }
    
    func testEncrypt_Decrypt_Decoder() throws {
        
        let sample = ProductType.account
        let publicKey = try provider.getPublicKey()
        let encryptor = Encryptor(publicKey: publicKey, algorithm: provider.algorithm)
        let privateKey = try provider.getPrivateKey()
        let decryptor = Decryptor(privateKey: privateKey, algorithm: provider.algorithm)
        
        let encrypted = try encryptor.encryptChunked(sample)
        let decrypted: ProductType = try decryptor.decryptChunked(encrypted)
        
        XCTAssertEqual(decrypted, sample)
    }
}
