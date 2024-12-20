//
//  KeyExchangeTests.swift
//  
//
//  Created by Igor Malyarov on 02.10.2023.
//

import CVVPINServices
import XCTest

final class KeyExchangeTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallProcess() throws {
        
        let (sut, service, _, _) = makeSUT(
            makeECDHKeyPairStub: .failure(anyError()),
            signStub: .failure(anyError()),
            makeSymmetricKeyStub: .failure(anyError())
        )
        
        XCTAssertEqual(service.callCount, 0)
        _ = sut
    }
    
    // MARK: - exchangeKeys
    
    func test_exchangeKeys_shouldDeliverErrorOnMakeECDHKeyPairFailure() {
        
        let makeECDHKeyPairError = anyError("MakeECDHKeyPairFailure")
        let (sut, _, _, _) = makeSUT(
            makeECDHKeyPairStub: .failure(makeECDHKeyPairError),
            signStub: .failure(anyError()),
            makeSymmetricKeyStub: .failure(anyError())
        )
        
        assert(sut, delivers: .failure(.makeECDHKeyPairOrWrapInJSONFailure))
    }
    
    func test_exchangeKeys_shouldDeliverErrorOnSignFailure() {
        
        let keyPair = makeRSAKeyPair()
        let signError = anyError("SignFailure")
        let (sut, _, _, _) = makeSUT(
            makeECDHKeyPairStub: anySuccessECDHKeyPairStub(),
            signStub: .failure(signError),
            makeSymmetricKeyStub: .failure(anyError())
        )
        
        assert(sut, delivers: .failure(.makeECDHKeyPairOrWrapInJSONFailure), with: keyPair)
    }
    
    func test_exchangeKeys_shouldInvokeSigningWithPrivateKey() {
        
        let privateKeyValue = "Private Key Value"
        let keyPair = makeRSAKeyPair(privateKeyValue: privateKeyValue)
        let (sut, _, sign, _) = makeSUT(
            makeECDHKeyPairStub: anySuccessECDHKeyPairStub(),
            signStub: .failure(anyError()),
            makeSymmetricKeyStub: .failure(anyError())
        )
        
        assert(sut, delivers: .failure(.makeECDHKeyPairOrWrapInJSONFailure), with: keyPair)
        
        XCTAssertEqual(sign.messages.map(\.key), [.init(privateKeyValue)])
    }
    
    func test_exchangeKeys_shouldDeliverErrorOnServiceFailure() {
        
        let serviceError = anyKeyExchangeAPIError()
        let (sut, service, _, _) = makeSUT(
            makeECDHKeyPairStub: anySuccessECDHKeyPairStub(),
            signStub: anySuccessSignStub(),
            makeSymmetricKeyStub: .failure(anyError())
        )
        
        assert(sut, delivers: .failure(.apiError(serviceError)), on: {
            
            service.complete(with: .failure(serviceError))
        })
    }
    
    func test_exchangeKeys_shouldDeliverErrorOnMakeSymmetricKeyFailure() {
        
        let symmetricKeyError = anyError("MakeSymmetricKeyFailure")
        let (sut, service, _, _) = makeSUT(
            makeECDHKeyPairStub: anySuccessECDHKeyPairStub(),
            signStub: anySuccessSignStub(),
            makeSymmetricKeyStub: .failure(symmetricKeyError)
        )
        
        assert(sut, delivers: .failure(.makeSymmetricKeyFailure), on: {
            
            service.complete(with: anySuccess())
        })
    }
    
    func test_exchangeKeys_shouldDeliverResultOnSuccess() {
        
        let sessionKeyValue = "Symmetric Session Key"
        let (sut, service, _, _) = makeSUT(
            makeECDHKeyPairStub: anySuccessECDHKeyPairStub(),
            signStub: anySuccessSignStub(),
            makeSymmetricKeyStub: .success(.init(sessionKeyValue))
        )
        
        assert(sut, delivers: .success(.init(sessionKeyValue)), on: {
            
            service.complete(with: anySuccess())
        })
    }
    
    func test_exchangeKeys_shouldDeliverSuccessOnServiceSuccess() {
        
        let sessionKeyValue = "Symmetric Session Key"
        let privateKeyValue = "Private Key Value"
        let response = makePublicKeyAuthenticationResponse()
        let (sut, service, _, symmetricKey) = makeSUT(
            makeECDHKeyPairStub: .success(makeECDHKeyPair(privateKeyValue: privateKeyValue)),
            signStub: anySuccessSignStub(),
            makeSymmetricKeyStub: .success(.init(sessionKeyValue))
        )
        
        assert(sut, delivers: .success(.init(sessionKeyValue)), on: {
            
            service.complete(with: .success(response))
        })
        XCTAssertEqual(symmetricKey.messages.map(\.response), [response])
        XCTAssertEqual(symmetricKey.messages.map(\.key), [.init(privateKeyValue)])
    }
    
    // MARK: - Helpers
    
    fileprivate typealias APIError = ResponseMapper.KeyExchangeMapperError
    fileprivate typealias SUT = KeyExchange<APIError, ECDHPublicKey, ECDHPrivateKey, RSAPublicKey, RSAPrivateKey, SymmetricKey>
    private typealias ECDHKeyPairDomain = KeyPairDomain<ECDHPublicKey, ECDHPrivateKey>
    typealias Success = PublicKeyAuthenticationResponse
    private typealias AuthResult = Result<PublicKeyAuthenticationResponse, APIError>
    private typealias AuthServiceSpy = RemoteServiceSpy<PublicKeyAuthenticationResponse, APIError, Data>
    
    private func makeSUT(
        makeECDHKeyPairStub: ECDHKeyPairDomain.Result,
        signStub: Result<Data, Error>,
        makeSymmetricKeyStub: Result<SymmetricKey, Error>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        service: AuthServiceSpy,
        sign: SignSpy,
        symmetricKeySpy: MakeSymmetricKeySpy
    ) {
        let service = AuthServiceSpy()
        let sign = SignSpy(stub: signStub)
        let makeSymmetricKey = MakeSymmetricKeySpy(
            stub: makeSymmetricKeyStub
        )
        let sut = SUT(
            makeECDHKeyPair: { try makeECDHKeyPairStub.get() },
            sign: sign.sign(data:key:),
            process: service.process(_:completion:),
            makeSymmetricKey: makeSymmetricKey.makeSymmetricKey(response:key:)
        )
        
        // trackForMemoryLeaks(sut, file: file, line: line)
        // trackForMemoryLeaks(service, file: file, line: line)
        
        return (sut, service, sign, makeSymmetricKey)
    }
    
    private final class SignSpy {
        
        private let stub: Result<Data, Error>
        private(set) var messages = [(data: Data, key: RSAPrivateKey)]()
        
        init(stub: Result<Data, Error>) {
            
            self.stub = stub
        }
        
        func sign(data: Data, key: RSAPrivateKey) throws -> Data {
            
            messages.append((data, key))
            
            return try stub.get()
        }
    }
    
    private final class MakeSymmetricKeySpy {
        
        typealias Response = PublicKeyAuthenticationResponse
        typealias Message = (response: Response, key: ECDHPrivateKey)
        private(set) var messages = [Message]()
        private let stub: Result<SymmetricKey, Error>
        
        init(stub: Result<SymmetricKey, Error>) {
            
            self.stub = stub
        }
        
        func makeSymmetricKey(
            response: Success,
            key: ECDHPrivateKey
        ) throws -> SymmetricKey {
            
            messages.append((response, key))
            
            return try stub.get()
        }
    }
    
    private func anyKeyExchangeError(
    ) -> KeyExchangeError<APIError> {
        
        .apiError(anyKeyExchangeAPIError())
    }
    
    private func anyKeyExchangeAPIError(
        statusCode: Int = 1234,
        errorMessage: String = "error message"
    ) -> APIError {
        
        .error(
            statusCode: statusCode,
            errorMessage: errorMessage
        )
    }
    
    private func anySuccessECDHKeyPairStub() -> ECDHKeyPairDomain.Result {
        
        .success(makeECDHKeyPair())
    }
    
    private func anySuccessSignStub() -> Result<Data, Error> {
        
        .success("any data".data(using: .utf8)!)
    }
    
    private func anySuccess() -> AuthResult {
        
        .success(makePublicKeyAuthenticationResponse())
    }
    
    private func assert(
        _ sut: SUT,
        delivers expected: SUT.ExchangeKeysResult,
        with keyPair: RSAKeyPair = makeRSAKeyPair(),
        on action: () throws -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var results = [SUT.ExchangeKeysResult]()
        let exp = expectation(description: "wait for completion")
        
        sut.exchangeKeys(rsaKeyPair: keyPair) {
            
            results.append($0)
            exp.fulfill()
        }
        
        try? action()
        
        wait(for: [exp], timeout: 1)
        
        assert(results, equalsTo: [expected], file: file, line: line)
    }
}
