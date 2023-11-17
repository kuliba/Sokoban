//
//  PublicKeyAuthenticationResponseMapperDecoratorTests.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

import CVVPINServices
import XCTest

final class PublicKeyAuthenticationResponseMapperDecoratorTests: MapperHelpers {
    
    func test_makeSymmetricKey_shouldNotCallSaveOnDecryptionError() throws {
        
        let publicTransportDecryptError = anyError("PublicTransportDecryptError")
        let (sut, _, saveSpy) = makeSUT(
            decryptionStub: .failure(publicTransportDecryptError),
            symmetricKeyStub: .failure(anyError())
        )
        
        _ = try? sut.makeSymmetricKey()
        
        XCTAssertEqual(saveSpy.requests.count, 0)
    }
    
    func test_makeSymmetricKey_shouldNotCallSaveOnMakeSymmetricKeyError() throws {
        
        let makeSymmetricKeyError = anyError("MakeSymmetricKeyError")
        let (sut, _, saveSpy) = makeSUT(
            decryptionStub: .success(.init()),
            symmetricKeyStub: .failure(makeSymmetricKeyError)
        )
        
        _ = try? sut.makeSymmetricKey()
        
        XCTAssertEqual(saveSpy.requests.count, 0)
    }
    
    func test_makeSymmetricKey_shouldCallSaveOnSuccess() throws {
        
        let (sut, _, saveSpy) = makeSUT(
            decryptionStub: .success(.init()),
            symmetricKeyStub: .success(.init("key"))
        )
        
        _ = try sut.makeSymmetricKey()
        
        XCTAssertEqual(saveSpy.requests.count, 1)
    }
    
    func test_makeSymmetricKey_bothMapperAndDecoratorShouldFailOnDecryptionError() throws {
        
        let publicTransportDecryptError = anyError("PublicTransportDecryptError")
        let (sut, mapper, _) = makeSUT(
            decryptionStub: .failure(publicTransportDecryptError),
            symmetricKeyStub: .failure(anyError())
        )
        
        try XCTAssertThrowsAsNSError(
            sut.makeSymmetricKey(),
            error: publicTransportDecryptError
        )
        
        try XCTAssertThrowsAsNSError(
            mapper.makeSymmetricKey(),
            error: publicTransportDecryptError
        )
    }
    
    func test_makeSymmetricKey_bothMapperAndDecoratorShouldFailOnMakeSymmetricKeyError() throws {
        
        let makeSymmetricKeyError = anyError("MakeSymmetricKeyError")
        let (sut, mapper, _) = makeSUT(
            decryptionStub: .success(.init()),
            symmetricKeyStub: .failure(makeSymmetricKeyError)
        )
        
        try XCTAssertThrowsAsNSError(
            sut.makeSymmetricKey(),
            error: makeSymmetricKeyError
        )
        
        try XCTAssertThrowsAsNSError(
            mapper.makeSymmetricKey(),
            error: makeSymmetricKeyError
        )
    }
    
    func test_makeSymmetricKey_shouldCreateSameSymmetricKeyAsMapper() throws {
        
        let (sut, mapper, _) = makeSUT(
            decryptionStub: .success(.init()),
            symmetricKeyStub: .success(.init("key"))
        )
        
        let decorated = try sut.makeSymmetricKey()
        let symmetricKey = try mapper.makeSymmetricKey()
        
        XCTAssertEqual(decorated, symmetricKey)
        XCTAssertEqual(symmetricKey, .init("key"))
        
    }
    
    // MARK: - Helpers
    
    fileprivate typealias Decorator = PublicKeyAuthenticationResponseMapperDecorator<ECDHPrivateKey, SymmetricKey>
    
    private func makeSUT(
        decryptionStub: Result<Data, Error>,
        symmetricKeyStub: Result<SymmetricKey, Error>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: Decorator,
        mapper: Mapper,
        saveSpy: SaveSpy
    ) {
        let mapper = Mapper(
            publicTransportDecrypt: { _ in try decryptionStub.get() },
            makeSymmetricKey: { _,_ in try symmetricKeyStub.get() }
        )
        let saveSpy = SaveSpy()
        
        let sut = Decorator(decoratee: mapper, save: saveSpy.save)
        
        trackForMemoryLeaks(mapper, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(saveSpy, file: file, line: line)
        
        return (sut, mapper, saveSpy)
    }
    
    private final class SaveSpy {
        
        private(set) var requests = [Request]()
        
        func save(
            symmetricKey: SymmetricKey,
            sessionID: Decorator.SessionID,
            ttl: Decorator.TTL
        ) {
            requests.append(.init(symmetricKey: symmetricKey, sessionID: sessionID, ttl: ttl))
        }
        
        struct Request {
            
            let symmetricKey: SymmetricKey
            let sessionID: Decorator.SessionID
            let ttl: Decorator.TTL
        }
    }
}
