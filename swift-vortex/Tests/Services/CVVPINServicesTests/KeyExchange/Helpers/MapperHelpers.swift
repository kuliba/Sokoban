//
//  MapperHelpers.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

@testable import CVVPINServices
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

func validPublicServerSessionKeyValue() -> String {
    
    anyData().base64EncodedString()
}

extension PublicKeyAuthenticationResponseMapperTests.Mapper {
    
    func makeSymmetricKey(
        keyValue: String = validPublicServerSessionKeyValue(),
        sessionID sessionIDValue: String = UUID().uuidString,
        ttl: TimeInterval = 123
    ) throws -> SymmetricKey {
        
        try self.makeSymmetricKey(
            from: .init(
                publicServerSessionKey: .init(value: keyValue),
                sessionID: .init(value: sessionIDValue),
                sessionTTL: ttl
            ),
            with: .init()
        )
    }
}

extension PublicKeyAuthenticationResponseMapperDecorator
where ECDHPrivateKey == MapperHelpers.ECDHPrivateKey {
    
    func makeSymmetricKey(
        keyValue: String = validPublicServerSessionKeyValue(),
        sessionID sessionIDvalue: String = UUID().uuidString,
        ttl: TimeInterval = 123
    ) throws -> SymmetricKey {
        
        try self.makeSymmetricKey(
            .init(
                publicServerSessionKey: .init(value: keyValue),
                sessionID: .init(value: sessionIDvalue),
                sessionTTL: ttl
            ),
            with: .init()
        )
    }
}
