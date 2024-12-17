//
//  CachingKeyGeneratorDecoratorTests.swift
//  
//
//  Created by Igor Malyarov on 17.08.2023.
//

import CryptoKit
import ForaCrypto
import XCTest

final class CachingKeyGeneratorDecoratorTests: XCTestCase {
    
    func test_generateKeyPair_shouldDeliverErrorOnKeyGenerationError() throws {
        
        let keyGenerationError = anyError("key generation")
        let (sut, keyGeneratorSpy, _) = makeSUT()
        
        expect(
            sut: sut,
            toDeliver: .failure(keyGenerationError),
            on: {
                keyGeneratorSpy.complete(with: .failure(keyGenerationError))
            }
        )
    }
    
    func test_generateKeyPair_shouldDeliverErrorOnKeyCachingError() throws {
        
        let keyCachingError = anyError("key caching")
        let generateKeyPair = generateP384KeyPair
        let (sut, keyGeneratorSpy, keyCacheSpy) = makeSUT()
        
        expect(
            sut: sut,
            toDeliver: .failure(keyCachingError),
            on: {
                keyGeneratorSpy.complete(with: .success(generateKeyPair()))
                keyCacheSpy.complete(with: .failure(keyCachingError))
            }
        )
    }
    
    func test_generateKeyPair_shouldDeliverGeneratedKeys() throws {
        
        let keyPair = generateP384KeyPair()
        let (sut, keyGeneratorSpy, keyCacheSpy) = makeSUT()
        
        expect(
            sut: sut,
            toDeliver: .success(keyPair),
            on: {
                keyGeneratorSpy.complete(with: .success(keyPair))
                keyCacheSpy.complete(with: .success(()))
            }
        )
    }
    
    func test_generateP384KeyPair_shouldGeneratePublicKeyLinkedToPrivate() {
        
        let (privateKey, publicKey) = generateP384KeyPair()
        
        XCTAssertEqual(
            publicKey.derRepresentation,
            privateKey.publicKey.derRepresentation
        )
    }
    
    // MARK: - Helpers
    
    private let generateP384KeyPair = Crypto.generateP384KeyPair
    
    private typealias Decorator = CachingKeyGeneratorDecorator<
        P384.KeyAgreement.PrivateKey,
        P384.KeyAgreement.PublicKey
    >
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: Decorator,
        keyGeneratorSpy: KeyGeneratorSpy,
        keyCacheSpy: KeyCacheSpy
    ) {
        
        let keyGeneratorSpy = KeyGeneratorSpy()
        let keyCacheSpy = KeyCacheSpy()
        
        let sut = Decorator(
            decoratee: keyGeneratorSpy.generateKeyPair,
            cacheKey: keyCacheSpy.saveKey
        )
        
        trackForMemoryLeaks(keyGeneratorSpy, file: file, line: line)
        trackForMemoryLeaks(keyCacheSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, keyGeneratorSpy, keyCacheSpy)
    }
    
    private final class KeyGeneratorSpy {
        
        typealias KeyPair = Decorator.KeyPair
        typealias Result = Swift.Result<KeyPair, Error>
        typealias Completion = (Result) -> Void
        
        var completions = [Completion]()
        
        func generateKeyPair(
            completion: @escaping Completion
        ) {
            completions.append(completion)
        }
        
        func complete(
            with result: Result,
            at index: Int = 0
        ) {
            completions[index](result)
        }
    }
    
    private typealias Result = Swift.Result<Decorator.KeyPair, Error>
    
    private func expect(
        sut: Decorator,
        toDeliver expectedResult: Result,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.generateKeyPair { receivedResult in
            
            switch (receivedResult, expectedResult) {
            case let (
                .failure(receivedError as NSError),
                .failure(expectedError as NSError)
            ):
                XCTAssertEqual(
                    receivedError,
                    expectedError,
                    file: file, line: line
                )
                
            case let (
                .success(receivedPair),
                .success(expectedPair)
            ):
                XCTAssertEqual(
                    receivedPair.privateKey.derRepresentation,
                    expectedPair.privateKey.derRepresentation,
                    file: file, line: line
                )
                XCTAssertEqual(
                    receivedPair.publicKey.derRepresentation,
                    expectedPair.publicKey.derRepresentation,
                    file: file, line: line
                )
                
            default:
                XCTFail(file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private final class KeyCacheSpy {
        
        typealias Key = P384.KeyAgreement.PrivateKey
        typealias Domain = KeyCacheDomain<Key>
        typealias Result = Domain.Result
        typealias Completion = Domain.Completion
        
        private var completions = [Completion]()
        
        func saveKey(
            key: Key,
            completion: @escaping Completion
        ) {
            completions.append(completion)
        }
        
        func complete(
            with result: Result,
            at index: Int = 0
        ) {
            completions[index](result)
        }
    }
}

func anyError(
    _ domain: String = "any error",
    _ code: Int = 0
) -> Error {
    
    NSError(domain: domain, code: code)
}
