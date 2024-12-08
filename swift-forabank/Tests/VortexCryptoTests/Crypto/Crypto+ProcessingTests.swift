//
//  Crypto+ProcessingTests.swift
//  
//
//  Created by Igor Malyarov on 25.10.2023.
//

import VortexCrypto
import XCTest

final class Crypto_ProcessingTests: XCTestCase {
    
    func test_fileExists() {
        
        _ = processingPemURL
    }
    
    func test_pextractPublicKey_shouldFailForNonPemString() throws {
        
        let nonPem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        
        try XCTAssertThrowsError(Crypto.extractPublicKey(fromPEM: nonPem))
    }
    
    func test_extractPublicKey_extractsKeyForEncryption() throws {
        
        let contents = try String(contentsOf: processingPemURL)
        let key = try Crypto.extractPublicKey(fromPEM: contents)
        
        let algorithms: [SecKeyAlgorithm] = [
            //    .rsaSignatureMessagePKCS1v15SHA256,
            //    .rsaSignatureMessagePKCS1v15SHA384,
            //    .rsaSignatureMessagePKCS1v15SHA512,
            //    .rsaSignatureMessagePSSSHA256,
            //    .rsaSignatureMessagePSSSHA384,
            //    .rsaSignatureMessagePSSSHA512,
            //    .rsaEncryptionOAEPSHA1,
            //    .rsaEncryptionOAEPSHA256,
            .rsaEncryptionPKCS1,
            .rsaEncryptionRaw
        ]
        
        algorithms.forEach {
            
            XCTAssert(SecKeyIsAlgorithmSupported(key, .encrypt, $0))
            XCTAssert(SecKeyIsAlgorithmSupported(key, .decrypt, $0))
        }
    }
    
    func test_processingKey_extractsKeyForEncryption() throws {
        
        let contents = try String(contentsOf: processingPemURL)
        let key = try Crypto.extractPublicKey(fromPEM: contents)
        
        let algorithms: [SecKeyAlgorithm] = [
            //    .rsaSignatureMessagePKCS1v15SHA256,
            //    .rsaSignatureMessagePKCS1v15SHA384,
            //    .rsaSignatureMessagePKCS1v15SHA512,
            //    .rsaSignatureMessagePSSSHA256,
            //    .rsaSignatureMessagePSSSHA384,
            //    .rsaSignatureMessagePSSSHA512,
            //    .rsaEncryptionOAEPSHA1,
            //    .rsaEncryptionOAEPSHA256,
            .rsaEncryptionPKCS1,
            .rsaEncryptionRaw
        ]
        
        algorithms.forEach {
            
            XCTAssert(SecKeyIsAlgorithmSupported(key, .encrypt, $0))
            XCTAssert(SecKeyIsAlgorithmSupported(key, .decrypt, $0))
        }
    }
}

import Foundation
import Security
