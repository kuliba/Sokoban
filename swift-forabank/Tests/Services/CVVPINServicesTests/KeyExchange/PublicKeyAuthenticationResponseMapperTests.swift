//
//  PublicKeyAuthenticationResponseMapperTests.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

import CVVPINServices
import XCTest

final class PublicKeyAuthenticationResponseMapperTests: MapperHelpers {
    
    func test_makeSymmetricKey_shouldFailOnPublicTransportDecryptError() throws {
        
        let publicTransportDecryptError = anyError("PublicTransportDecryptError")
        let sut = makeSUT(
            decryptionStub: .failure(publicTransportDecryptError),
            symmetricKeyStub: .failure(anyError())
        )
        
        try XCTAssertThrowsAsNSError(
            sut.makeSymmetricKey(),
            error: publicTransportDecryptError
        )
    }
    
    func test_makeSymmetricKey_shouldFailOnMakeSymmetricKeyError() throws {
        
        let makeSymmetricKeyError = anyError("SymmetricKeyError")
        let sut = makeSUT(
            decryptionStub: .success(.init()),
            symmetricKeyStub: .failure(makeSymmetricKeyError)
        )
        
        try XCTAssertThrowsAsNSError(
            sut.makeSymmetricKey(),
            error: makeSymmetricKeyError
        )
    }
    
    func test_makeSymmetricKey_shouldDeliverSymmetricKeyOnSuccess() throws {
        
        let sut = makeSUT(
            decryptionStub: .success(.init()),
            symmetricKeyStub: .success(.init("key"))
        )
        
        let symmetricKey = try sut.makeSymmetricKey()
        
        XCTAssertEqual(symmetricKey, .init("key"))
    }
}
