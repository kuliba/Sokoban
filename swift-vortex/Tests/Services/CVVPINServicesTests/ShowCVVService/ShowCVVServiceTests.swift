//
//  ShowCVVServiceTests.swift
//  
//
//  Created by Igor Malyarov on 03.10.2023.
//

import CVVPINServices
import XCTest

final class ShowCVVServiceTests: XCTestCase {
    
    func test_init_shouldNotMessageCollaborators() {
        
        let (_, keyPairLoader, sessionIDLoader, symmetricKeyLoader, service) = makeSUT()
        
        XCTAssertEqual(keyPairLoader.callCount, 0)
        XCTAssertEqual(sessionIDLoader.callCount, 0)
        XCTAssertEqual(symmetricKeyLoader.callCount, 0)
        XCTAssertEqual(service.callCount, 0)
    }
    
    func test_showCVV_shouldDeliverErrorOnKeyLoaderFailure() {
        
        let loadError = anyError("Key Load Error")
        let (sut, keyPairLoader, _, _, _) = makeSUT()
        
        assert(sut, delivers: .failure(.missing(.rsaKeyPair)), on: {
            
            keyPairLoader.complete(with: .failure(loadError))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnSessionIDLoaderFailure() {
        
        let loadError = anyError("SessionID Load Error")
        let (sut, keyPairLoader, sessionIDLoader, _, _) = makeSUT()
        
        assert(sut, delivers: .failure(.missing(.sessionID)), on: {
            
            keyPairLoader.complete(with: anySuccess())
            sessionIDLoader.complete(with: .failure(loadError))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnMakeJSONFailure() {
        
        let makeJSONError = anyError("SessionID Load Error")
        let (sut, keyPairLoader, sessionIDLoader, symmetricKeyLoader, _) = makeSUT(makeJSON: { _,_,_,_,_  in throw makeJSONError })
        
        assert(sut, delivers: .failure(.makeJSONFailure), on: {
            
            keyPairLoader.complete(with: anySuccess())
            sessionIDLoader.complete(with: anySuccess())
            symmetricKeyLoader.complete(with: anySuccess())
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnSymmetricKeyLoaderFailure() {
        
        let loadSymmetricKeyError = anyError("SymmetricKey Load Error")
        let (sut, keyPairLoader, sessionIDLoader, symmetricKeyLoader, _) = makeSUT()
        
        assert(sut, delivers: .failure(.missing(.symmetricKey)), on: {
            
            keyPairLoader.complete(with: anySuccess())
            sessionIDLoader.complete(with: anySuccess())
            symmetricKeyLoader.complete(with: .failure(loadSymmetricKeyError))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnServicerFailure() {
        
        let serviceError = APIError.error(statusCode: 1234, errorMessage: "error message")
        let (sut, keyPairLoader, sessionIDLoader, symmetricKeyLoader, service) = makeSUT()
        
        assert(sut, delivers: .failure(.apiError(serviceError)), on: {
            
            keyPairLoader.complete(with: anySuccess())
            sessionIDLoader.complete(with: anySuccess())
            symmetricKeyLoader.complete(with: anySuccess())
            service.complete(with: .failure(serviceError))
        })
    }
    
    func test_showCVV_shouldDeliverErrorOnTranscodeCVVFailure() {
        
        let transcodeCVVError = anyError("TranscodeCVV Error")
        let (sut, keyPairLoader, sessionIDLoader, symmetricKeyLoader, service) = makeSUT(
            transcodeCVV: { _,_ in throw transcodeCVVError }
        )
        
        assert(sut, delivers: .failure(.transcodeFailure), on: {
            
            keyPairLoader.complete(with: anySuccess())
            sessionIDLoader.complete(with: anySuccess())
            symmetricKeyLoader.complete(with: anySuccess())
            service.complete(with: anySuccess())
        })
    }
    
    func test_showCVV_shouldDeliverResultOnSuccess() {
        
        let cvvValue = "0987"
        let (sut, keyPairLoader, sessionIDLoader, symmetricKeyLoader, service) = makeSUT()
        
        assert(sut, delivers: .success(.init(rawValue: cvvValue)), on: {
            
            keyPairLoader.complete(with: anySuccess())
            sessionIDLoader.complete(with: anySuccess())
            symmetricKeyLoader.complete(with: anySuccess())
            service.complete(with: anySuccess(cvvValue))
        })
    }
    
    func test_showCVV_shouldNotDeliverKeyLoadErrorOnInstanceDeallocation() {
        
        let (infra, keyPairLoader, _, _, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makeJSON: { _,_,_,_,_  in .init() },
            transcodeCVV: { remoteCVV, _ in .init(rawValue: remoteCVV.rawValue) }
        )
        var results = [SUT.CVVDomain.Result]()
        
        sut?.showCVV { results.append($0) }
        sut = nil
        keyPairLoader.complete(with: anyFailure())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(results.isEmpty)
    }
    
    func test_showCVV_shouldNotDeliverKeyLoadResultOnInstanceDeallocation() {
        
        let (infra, keyPairLoader, _, _, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makeJSON: { _,_,_,_,_  in .init() },
            transcodeCVV: { remoteCVV, _ in .init(rawValue: remoteCVV.rawValue) }
        )
        var results = [SUT.CVVDomain.Result]()
        
        sut?.showCVV { results.append($0) }
        sut = nil
        keyPairLoader.complete(with: anySuccess())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(results.isEmpty)
    }
    
    func test_showCVV_shouldNotDeliverSessionIDLoadErrorOnInstanceDeallocation() {
        
        let (infra, keyPairLoader, sessionIDLoader, _, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makeJSON: { _,_,_,_,_  in .init() },
            transcodeCVV: { remoteCVV, _ in .init(rawValue: remoteCVV.rawValue) }
        )
        var results = [SUT.CVVDomain.Result]()
        
        sut?.showCVV { results.append($0) }
        keyPairLoader.complete(with: anySuccess())
        sut = nil
        sessionIDLoader.complete(with: anyFailure())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(results.isEmpty)
    }
    
    func test_showCVV_shouldNotDeliverSessionIDLoadResultOnInstanceDeallocation() {
        
        let (infra, keyPairLoader, sessionIDLoader, _, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makeJSON: { _,_,_,_,_  in .init() },
            transcodeCVV: { remoteCVV, _ in .init(rawValue: remoteCVV.rawValue) }
        )
        var results = [SUT.CVVDomain.Result]()
        
        sut?.showCVV { results.append($0) }
        keyPairLoader.complete(with: anySuccess())
        sut = nil
        sessionIDLoader.complete(with: anySuccess())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(results.isEmpty)
    }
    
    func test_showCVV_shouldNotDeliverSymmetricKeyLoadErrorOnInstanceDeallocation() {
        
        let (infra, keyPairLoader, sessionIDLoader, symmetricKeyLoader, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makeJSON: { _,_,_,_,_  in .init() },
            transcodeCVV: { remoteCVV, _ in .init(rawValue: remoteCVV.rawValue) }
        )
        var results = [SUT.CVVDomain.Result]()
        
        sut?.showCVV { results.append($0) }
        keyPairLoader.complete(with: anySuccess())
        sessionIDLoader.complete(with: anySuccess())
        sut = nil
        symmetricKeyLoader.complete(with: anyFailure())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(results.isEmpty)
    }
    
    func test_showCVV_shouldNotDeliverSymmetricKeyLoadResultOnInstanceDeallocation() {
        
        let (infra, keyPairLoader, sessionIDLoader, symmetricKeyLoader, _) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makeJSON: { _,_,_,_,_  in .init() },
            transcodeCVV: { remoteCVV, _ in .init(rawValue: remoteCVV.rawValue) }
        )
        var results = [SUT.CVVDomain.Result]()
        
        sut?.showCVV { results.append($0) }
        keyPairLoader.complete(with: anySuccess())
        sessionIDLoader.complete(with: anySuccess())
        sut = nil
        symmetricKeyLoader.complete(with: anySuccess())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(results.isEmpty)
    }
    
    func test_showCVV_shouldNotDeliverServiceErrorLoadErrorOnInstanceDeallocation() {
        
        let (infra, keyPairLoader, sessionIDLoader, symmetricKeyLoader, service) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makeJSON: { _,_,_,_,_  in .init() },
            transcodeCVV: { remoteCVV, _ in .init(rawValue: remoteCVV.rawValue) }
        )
        var results = [SUT.CVVDomain.Result]()
        
        sut?.showCVV { results.append($0) }
        keyPairLoader.complete(with: anySuccess())
        sessionIDLoader.complete(with: anySuccess())
        symmetricKeyLoader.complete(with: anySuccess())
        sut = nil
        service.complete(with: anyFailure())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(results.isEmpty)
    }
    
    func test_showCVV_shouldNotDeliverServiceResultLoadResultOnInstanceDeallocation() {
        
        let (infra, keyPairLoader, sessionIDLoader, symmetricKeyLoader, service) = makeInfra()
        var sut: SUT? = .init(
            infra: infra,
            makeJSON: { _,_,_,_,_  in .init() },
            transcodeCVV: { remoteCVV, _ in .init(rawValue: remoteCVV.rawValue) }
        )
        var results = [SUT.CVVDomain.Result]()
        
        sut?.showCVV { results.append($0) }
        keyPairLoader.complete(with: anySuccess())
        sessionIDLoader.complete(with: anySuccess())
        symmetricKeyLoader.complete(with: anySuccess())
        sut = nil
        service.complete(with: .success(.init(rawValue: "9876")))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(results.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias APIError = ResponseMapper.ShowCVVMapperError
    private typealias SUT = ShowCVVService<APIError, CardID, RemoteCVV, CVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
    private typealias KeyPairLoaderSpy = LoaderSpyOf<RSAKeyPairDomain.KeyPair>
    private typealias SessionIDLoaderSpy = LoaderSpyOf<SessionID>
    private typealias SymmetricKeyLoaderSpy = LoaderSpyOf<SymmetricKey>
    private typealias PINServiceSpy = RemoteServiceSpy<RemoteCVV, APIError, (SessionID, Data)>
    
    private func makeSUT(
        makeJSON: SUT.MakeJSON? = nil,
        transcodeCVV: SUT.TranscodeCVV? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        keyPairLoader: KeyPairLoaderSpy,
        sessionIDLoader: SessionIDLoaderSpy,
        symmetricKeyLoader: SymmetricKeyLoaderSpy,
        service: PINServiceSpy
    ) {
        let (infra, keyPairLoader, sessionIDLoader, symmetricKeyLoader, service) = makeInfra(file: file, line: line)
        let makeJSON = makeJSON ?? { _,_,_,_,_ in .init() }
        let transcodeCVV = transcodeCVV ?? { remoteCVV, _ in .init(rawValue: remoteCVV.rawValue) }
        let sut = SUT(
            infra: infra,
            makeJSON: makeJSON,
            transcodeCVV: transcodeCVV
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, keyPairLoader, sessionIDLoader, symmetricKeyLoader, service)
    }
    
    private func makeInfra(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        infra: SUT.Infra,
        keyPairLoader: KeyPairLoaderSpy,
        sessionIDLoader: SessionIDLoaderSpy,
        symmetricKeyLoader: SymmetricKeyLoaderSpy,
        service: PINServiceSpy
    ) {
        let keyPairLoader = KeyPairLoaderSpy()
        let sessionIDLoader = SessionIDLoaderSpy()
        let symmetricKeyLoader = SymmetricKeyLoaderSpy()
        let service = PINServiceSpy()
        
        let infra = SUT.Infra(
            loadRSAKeyPair: keyPairLoader.load(completion:),
            loadSessionID: sessionIDLoader.load(completion:),
            loadSymmetricKey: symmetricKeyLoader.load(completion:),
            process: service.process
        )
        
        trackForMemoryLeaks(keyPairLoader, file: file, line: line)
        trackForMemoryLeaks(sessionIDLoader, file: file, line: line)
        trackForMemoryLeaks(symmetricKeyLoader, file: file, line: line)
        trackForMemoryLeaks(service, file: file, line: line)
        
        return (infra, keyPairLoader, sessionIDLoader, symmetricKeyLoader, service)
    }
    
    private func anyFailure(
        _ domain: String = "any error"
    ) -> SUT.RSAKeyPairDomain.Result {
        
        .failure(anyError(domain))
    }
    
    private func anyFailure(
        _ domain: String = "any error"
    ) -> ShowCVVServiceTests.SUT.Infra.SessionIDDomain.Result {
        
        .failure(anyError(domain))
    }
    
    private func anyFailure(
        _ domain: String = "any error"
    ) -> ShowCVVServiceTests.SUT.Infra.ServiceDomain.Result {
        
        .failure(.error(statusCode: 1234, errorMessage: "error message"))
    }
    
    private func anyFailure(
        _ domain: String = "any error"
    ) -> ShowCVVServiceTests.SUT.Infra.SymmetricKeyDomain.Result {
        
        .failure(anyError(domain))
    }
    
    private func anySuccess() -> SUT.RSAKeyPairDomain.Result {
        
        .success(makeRSAKeyPair())
    }
    
    private func anySuccess(
        _ sessionIDValue: String = UUID().uuidString
    ) -> ShowCVVServiceTests.SUT.Infra.SessionIDDomain.Result {
        
        .success(.init(rawValue: sessionIDValue))
    }
    
    private func anySuccess(
        _ symmetricKeyValue: String = UUID().uuidString
    ) -> ShowCVVServiceTests.SUT.Infra.SymmetricKeyDomain.Result {
        
        .success(.init(symmetricKeyValue))
    }
    
    private func anySuccess(
        _ cvvValue: String = "123456"
    ) -> ShowCVVServiceTests.SUT.Infra.ServiceDomain.Result {
        
        .success(.init(rawValue: cvvValue))
    }
    
    private func assert(
        _ sut: SUT,
        delivers expected: SUT.CVVDomain.Result,
        with cardID: CardID = .init(rawValue: 12_345),
        on action: () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var results = [SUT.CVVDomain.Result]()
        let exp = expectation(description: "wait for completion")
        
        sut.showCVV(forCardWithID: cardID) {
            
            results.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        assert(results, equalsTo: [expected], file: file, line: line)
    }
}

// MARK: - DSL

private extension ShowCVVService {
    
    func showCVV(completion: @escaping CVVCompletion) {
        
        self.showCVV(
            forCardWithID: .init(rawValue: 123_456)!,
            completion: completion
        )
    }
}
