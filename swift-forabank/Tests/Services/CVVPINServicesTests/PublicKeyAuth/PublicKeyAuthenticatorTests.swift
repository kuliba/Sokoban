//
//  PublicKeyAuthenticatorTests.swift
//  
//
//  Created by Igor Malyarov on 01.10.2023.
//

import CVVPINServices
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
        
        assert(sut, delivers:.failure(.missing(.rsaKeyPair)), on: {
            
            rsaKeyPairLoader.complete(with: .failure(loadRSAKeyPairError))
        })
    }
    
    func test_authenticateWithPublicKey_shouldDeliverKeyExchangeErrorOnLoadSessionKeyWithEventFailureAndKeyExchangeFailure() {
        
        let loadSessionKeyWithEventError = anyError("LoadSessionKeyWithEventFailure")
        let keyExchangeError = anyKeyExchangeError()
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
        var results = [KeyExchangeResult]()
        
        sut?.authenticateWithPublicKey { results.append($0) }
        sut = nil
        rsaKeyPairLoader.complete(with: .failure(anyError()))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        assertVoid(results, equalsTo: [])
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverLoadRSAResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let rsaKeyPairLoader: RSAKeyPairLoaderSpy
        (sut, rsaKeyPairLoader, _, _) = makeSUT()
        var results = [KeyExchangeResult]()
        
        sut?.authenticateWithPublicKey { results.append($0) }
        sut = nil
        rsaKeyPairLoader.complete(with: anySuccess())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        assertVoid(results, equalsTo: [])
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverLoadSessionKeyWithEventErrorOnInstanceDeallocation() {
        
        var sut: SUT?
        let rsaKeyPairLoader: RSAKeyPairLoaderSpy
        let sessionKeyLoader: SessionKeyWithEventLoaderSpy
        (sut, rsaKeyPairLoader, sessionKeyLoader, _) = makeSUT()
        var results = [KeyExchangeResult]()
        
        sut?.authenticateWithPublicKey { results.append($0) }
        rsaKeyPairLoader.complete(with: anySuccess())
        sut = nil
        sessionKeyLoader.complete(with: anyFailure())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        assertVoid(results, equalsTo: [])
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverLoadSessionKeyWithEventResultOnInstanceDeallocatioKeyExchangeErrorn() {
        
        var sut: SUT?
        let rsaKeyPairLoader: RSAKeyPairLoaderSpy
        let sessionKeyLoader: SessionKeyWithEventLoaderSpy
        (sut, rsaKeyPairLoader, sessionKeyLoader, _) = makeSUT()
        var results = [KeyExchangeResult]()
        
        sut?.authenticateWithPublicKey { results.append($0) }
        rsaKeyPairLoader.complete(with: anySuccess())
        sut = nil
        sessionKeyLoader.complete(with: anySuccess())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        assertVoid(results, equalsTo: [])
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverExchangeKeysErrorOnInstanceDeallocation() {
        
        var sut: SUT?
        let rsaKeyPairLoader: RSAKeyPairLoaderSpy
        let sessionKeyLoader: SessionKeyWithEventLoaderSpy
        let keyExchange: KeyExchangeSpy
        (sut, rsaKeyPairLoader, sessionKeyLoader, keyExchange) = makeSUT()
        var results = [KeyExchangeResult]()
        
        sut?.authenticateWithPublicKey { results.append($0) }
        rsaKeyPairLoader.complete(with: anySuccess())
        sessionKeyLoader.complete(with: anyFailure())
        sut = nil
        keyExchange.complete(with: .failure(anyKeyExchangeError()))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        assertVoid(results, equalsTo: [])
    }
    
    func test_authenticateWithPublicKey_shouldNotDeliverExchangeKeysResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let rsaKeyPairLoader: RSAKeyPairLoaderSpy
        let sessionKeyLoader: SessionKeyWithEventLoaderSpy
        let keyExchange: KeyExchangeSpy
        (sut, rsaKeyPairLoader, sessionKeyLoader, keyExchange) = makeSUT()
        var results = [KeyExchangeResult]()
        
        sut?.authenticateWithPublicKey { results.append($0) }
        rsaKeyPairLoader.complete(with: anySuccess())
        sessionKeyLoader.complete(with: anyFailure())
        sut = nil
        keyExchange.complete(with: .success(()))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        assertVoid(results, equalsTo: [])
    }
    
    // MARK: - Helpers

    private typealias KeyServiceAPIError = Error
    private typealias KeyExchError = KeyExchangeError<KeyServiceAPIError>
    private typealias KeyExchangeResult = Result<Void, KeyExchError>

    private typealias SUT = PublicKeyAuthenticator<KeyServiceAPIError, RSAPublicKey, RSAPrivateKey>
    private typealias RSAKeyPairDomain = KeyPairDomain<RSAPublicKey, RSAPrivateKey>
    private typealias RSAKeyPairLoaderSpy = LoaderSpyOf<RSAKeyPairDomain.Success>
    private typealias SessionKeyWithEventLoaderSpy = LoaderSpyOf<SessionKeyWithEvent>
    private typealias KeyExchangeSpy = RemoteServiceSpy<Void, KeyExchError, (RSAPublicKey, RSAPrivateKey)>
    
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
        delivers expected: KeyExchangeResult,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var results = [KeyExchangeResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.authenticateWithPublicKey {
            
            results.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        assertVoid(results, equalsTo: [expected], file: file, line: line)
    }
    
    private func anyKeyExchangeError() -> KeyExchError {
        
        .apiError(anyAPIError())
    }
    
    private func anyAPIError() -> KeyServiceAPIError {
        
        anyError()
    }
}
