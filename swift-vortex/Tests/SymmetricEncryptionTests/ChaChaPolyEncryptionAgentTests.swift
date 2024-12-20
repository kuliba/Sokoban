//
//  ChaChaPolyEncryptionAgentTests.swift
//  
//
//  Created by Max Gribov on 21.07.2023.
//

import XCTest
import SymmetricEncryption
import CryptoKit

final class ChaChaPolyEncryptionAgentTests: XCTestCase {

    func test_initWithEmptyKeyData_encryptAndDecryptThrowsError() {
        
        let keyData = Data()
        let sut = makeSUT(keyData)
        
        XCTAssertThrowsError(try sut.encrypt(Data()))
        XCTAssertThrowsError(try sut.decrypt(Data()))
    }
    
    func test_encrypt_sourceDataDoNotMatchTheResultData() throws {
        
        let key = SymmetricKey(size: .bits256)
        let sut = makeSUT(key.rawRepresentation)
        let sampleData = Data(repeating: 5, count: 10)
        
        let result = try sut.encrypt(sampleData)
        
        XCTAssertNotEqual(result, sampleData)
    }
    
    func test_decrypt_resultDataMatchesSourceData() throws {
        
        let key = SymmetricKey(size: .bits256)
        let sut = makeSUT(key.rawRepresentation)
        let sampleData = Data(repeating: 5, count: 10)
        
        let encryptedData = try sut.encrypt(sampleData)
        let result = try sut.decrypt(encryptedData)
        
        XCTAssertEqual(result, sampleData)
    }
    
    //MARK: - Helpers
    
    func makeSUT(_ keyData: Data,
                 file: StaticString = #file,
                 line: UInt = #line) -> ChaChaPolyEncryptionAgent {
        
        let sut = ChaChaPolyEncryptionAgent(with: keyData)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
