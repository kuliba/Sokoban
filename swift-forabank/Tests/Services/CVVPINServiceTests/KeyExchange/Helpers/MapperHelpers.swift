//
//  MapperHelpers.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

@testable import CVVPINService
import XCTest

class MapperHelpers: XCTestCase {
    
    // MARK: - Helpers
    
    typealias Mapper = PublicKeyAuthenticationResponseMapper<ECDHPrivateKey, SymmetricKey>
    struct ECDHPrivateKey {}
    
    struct SymmetricKey: Equatable {
        
        let value: String
        
        init(_ value: String) {
            
            self.value = value
        }
    }
    
    func makeSUT(
        decryptionStub: Result<Data, Error>,
        symmetricKeyStub: Result<SymmetricKey, Error>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Mapper {
        
        let sut = Mapper(
            publicTransportDecrypt: { _ in try decryptionStub.get() },
            makeSymmetricKey: { _,_ in try symmetricKeyStub.get() }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func anyError(_ domain: String = "any error") -> Error {
        
        NSError(domain: domain, code: -1)
    }
}
