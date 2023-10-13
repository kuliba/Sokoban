//
//  PublicKeyAuthenticatorTests.swift
//  
//
//  Created by Igor Malyarov on 01.10.2023.
//

import CVVPINService
import XCTest

final class PublicKeyAuthenticatorTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, rsaKeyPairLoader, sessionKeyLoader, keyExchange) = makeSUT()
        
        XCTAssertEqual(rsaKeyPairLoader.callCount, 0)
        XCTAssertEqual(sessionKeyLoader.callCount, 0)
        XCTAssertEqual(keyExchange.callCount, 0)
        _ = sut
    }
    
    // MARK: - authenticateWithPublicKey
    
    func test_authenticateWithPublicKey_shouldDeliverErrorOnLoadRSAKeyPairFailure() {
        
        let loadRSAKeyPairError = anyError("LoadRSAKeyPairFailure")
        let (sut, rsaKeyPairLoader, _, _) = makeSUT()
        
        assert(sut, delivers:.failure(loadRSAKeyPairError), on: {
            
            rsaKeyPairLoader.complete(with: .failure(loadRSAKeyPairError))
        })
    }
    
    func test_authenticateWithPublicKey_shouldDeliverKeyExchangeErrorOnLoadSessionKeyWithEventFailureAndKeyExchangeFailure() {
        
        let loadSessionKeyWithEventError = anyError("LoadSessionKeyWithEventFailure")
        let keyExchangeError = anyError("KeyExchangeError")
        let (sut, rsaKeyPairLoader, sessionKeyLoader, keyExchange) = makeSUT()
        
        assert(sut, delivers:.failure(keyExchangeError), on: {
            
            rsaKeyPairLoader.complete(with: anySuccess())
            sessionKeyLoader.complete(with: .failure(loadSessionKeyWithEventError))
            keyExchange.complete(with: .failure(keyExchangeError))
        })
    }
    
    func test_authenticateWithPublicKey_shouldDeliverKeyExchangeResultOnLoadSessionKeyWithEventFailureAndKeyExchangeSuccess() {
        
        let loadSessionKeyWithEventError = anyError("LoadSessionKeyWithEventFailure")
        let (sut, rsaKeyPairLoader, sessionKeyLoader, keyExchange) = makeSUT()
        
        assert(sut, delivers:.success(()), on: {
            
            rsaKeyPairLoader.complete(with: anySuccess())
            sessionKeyLoader.complete(with: .failure(loadSessionKeyWithEventError))
            keyExchange.complete(with: .success(()))
        })
    }
    
    func test_authenticateWithPublicKey_shouldDeliverResultOnLoadSessionKeyWithEventSuccess() {
        
        let (sut, rsaKeyPairLoader, sessionKeyLoader, _) = makeSUT()
        
        assert(sut, delivers:.success(()), on: {
            
            rsaKeyPairLoader.complete(with: anySuccess())
            sessionKeyLoader.complete(with: anySuccess())
        })
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverLoadRSAErrorOnInstanceDeallocation() {
        
        var sut: SUT?
        let rsaKeyPairLoader: RSAKeyPairLoaderSpy
        (sut, rsaKeyPairLoader, _, _) = makeSUT()
        var results = [Result<Void, Error>]()
        
        sut?.authenticateWithPublicKey { results.append($0) }
        sut = nil
        rsaKeyPairLoader.complete(with: .failure(anyError()))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        assert(results, equalsTo: [])
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverLoadRSAResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let rsaKeyPairLoader: RSAKeyPairLoaderSpy
        (sut, rsaKeyPairLoader, _, _) = makeSUT()
        var results = [Result<Void, Error>]()
        
        sut?.authenticateWithPublicKey { results.append($0) }
        sut = nil
        rsaKeyPairLoader.complete(with: anySuccess())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        assert(results, equalsTo: [])
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverLoadSessionKeyWithEventErrorOnInstanceDeallocation() {
        
        var sut: SUT?
        let rsaKeyPairLoader: RSAKeyPairLoaderSpy
        let sessionKeyLoader: SessionKeyWithEventLoaderSpy
        (sut, rsaKeyPairLoader, sessionKeyLoader, _) = makeSUT()
        var results = [Result<Void, Error>]()
        
        sut?.authenticateWithPublicKey { results.append($0) }
        rsaKeyPairLoader.complete(with: anySuccess())
        sut = nil
        sessionKeyLoader.complete(with: anyFailure())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        assert(results, equalsTo: [])
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverLoadSessionKeyWithEventResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let rsaKeyPairLoader: RSAKeyPairLoaderSpy
        let sessionKeyLoader: SessionKeyWithEventLoaderSpy
        (sut, rsaKeyPairLoader, sessionKeyLoader, _) = makeSUT()
        var results = [Result<Void, Error>]()
        
        sut?.authenticateWithPublicKey { results.append($0) }
        rsaKeyPairLoader.complete(with: anySuccess())
        sut = nil
        sessionKeyLoader.complete(with: anySuccess())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        assert(results, equalsTo: [])
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverExchangeKeysErrorOnInstanceDeallocation() {
        
        var sut: SUT?
        let rsaKeyPairLoader: RSAKeyPairLoaderSpy
        let sessionKeyLoader: SessionKeyWithEventLoaderSpy
        let keyExchange: KeyExchangeSpy
        (sut, rsaKeyPairLoader, sessionKeyLoader, keyExchange) = makeSUT()
        var results = [Result<Void, Error>]()
        
        sut?.authenticateWithPublicKey { results.append($0) }
        rsaKeyPairLoader.complete(with: anySuccess())
        sessionKeyLoader.complete(with: anyFailure())
        sut = nil
        keyExchange.complete(with: .failure(anyError()))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        assert(results, equalsTo: [])
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverExchangeKeysResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let rsaKeyPairLoader: RSAKeyPairLoaderSpy
        let sessionKeyLoader: SessionKeyWithEventLoaderSpy
        let keyExchange: KeyExchangeSpy
        (sut, rsaKeyPairLoader, sessionKeyLoader, keyExchange) = makeSUT()
        var results = [Result<Void, Error>]()
        
        sut?.authenticateWithPublicKey { results.append($0) }
        rsaKeyPairLoader.complete(with: anySuccess())
        sessionKeyLoader.complete(with: anyFailure())
        sut = nil
        keyExchange.complete(with: .success(()))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        assert(results, equalsTo: [])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PublicKeyAuthenticator<RSAPublicKey, RSAPrivateKey>
    private typealias RSAKeyPairDomain = KeyPairDomain<RSAPublicKey, RSAPrivateKey>
    private typealias RSAKeyPairLoaderSpy = LoaderSpyOf<RSAKeyPairDomain.Success>
    private typealias SessionKeyWithEventLoaderSpy = LoaderSpyOf<SessionKeyWithEvent>
    private typealias KeyExchangeSpy = RemoteServiceSpy<Void, Error, (RSAPublicKey, RSAPrivateKey)>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        rsaKeyPairLoader: RSAKeyPairLoaderSpy,
        sessionKeyLoader: SessionKeyWithEventLoaderSpy,
        keyExchange: KeyExchangeSpy
    ) {
        let rsaKeyPairLoader = RSAKeyPairLoaderSpy()
        let sessionKeyLoader = SessionKeyWithEventLoaderSpy()
        let keyExchange = KeyExchangeSpy()
        let sut = SUT(
            infra: .init(
                loadRSAKeyPair: rsaKeyPairLoader.load,
                loadSessionKeyWithEvent: sessionKeyLoader.load
            ),
            exchangeKeys: keyExchange.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(rsaKeyPairLoader, file: file, line: line)
        trackForMemoryLeaks(sessionKeyLoader, file: file, line: line)
        trackForMemoryLeaks(keyExchange, file: file, line: line)
        
        return (sut, rsaKeyPairLoader, sessionKeyLoader, keyExchange)
    }
    
    private func anySuccess() -> RSAKeyPairLoaderSpy.Result {
        
        .success(makeRSAKeyPair())
    }
    
    private func anySuccess() -> SessionKeyWithEventLoaderSpy.Result {
        
        .success(makeSessionKeyWithEvent())
    }
    
    private func anyFailure() -> SessionKeyWithEventLoaderSpy.Result {
        
        .failure(anyError())
    }
    
    private func assert(
        _ sut: SUT,
        delivers expected: Result<Void, Error>,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var results = [Result<Void, Error>]()
        let exp = expectation(description: "wait for completion")
        
        sut.authenticateWithPublicKey {
            
            results.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        assert(results, equalsTo: [expected], file: file, line: line)
    }
}
