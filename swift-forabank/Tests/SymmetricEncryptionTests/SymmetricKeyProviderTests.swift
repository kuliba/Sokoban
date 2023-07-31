//
//  SymmetricKeyProviderTests.swift
//  
//
//  Created by Max Gribov on 21.07.2023.
//

import XCTest
import SymmetricEncryption
import CryptoKit

final class SymmetricKeyProviderTests: XCTestCase {
    
    func test_getSymmetricKeyRawRepresentation_validSymmetric256bitKeyRecreationFromData() {
        
        let sut = makeSUT(.bits256)
        
        let rawRepresentation = sut.getSymmetricKeyRawRepresentation()
        let key = SymmetricKey(data: rawRepresentation)
        
        XCTAssertEqual(key, sut.symmetricKey)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(_ size: SymmetricKeySize,
                         file: StaticString = #file,
                         line: UInt = #line) -> SymmetricKeyProvider {
        
        let sut = SymmetricKeyProvider(keySize: size)
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
