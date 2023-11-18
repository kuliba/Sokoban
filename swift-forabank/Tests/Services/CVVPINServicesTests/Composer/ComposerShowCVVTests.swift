//
//  ComposerShowCVVTests.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

@testable import CVVPINServices
import XCTest

final class ComposerShowCVVTests: MakeComposerInfraTests {
    
    func test_init_shouldNotMessageCollaborators() {
        
        let (_, showCVVService, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        XCTAssertEqual(showCVVService.callCount, 0)
        XCTAssertEqual(keyPairLoader.callCount, 0)
        XCTAssertEqual(sessionIDLoader.callCount, 0)
        XCTAssertEqual(symmetricKeyLoader.callCount, 0)
    }
    
    func test_showCVV_shouldDeliverErrorOnRSAKeyPairLoadFailure() {
        
        let loadRSAKeyPairError = anyError("RSAKeyPair Failure")
        let (sut, _, keyPairLoader, _, _) = makeSUT()
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .failure(loadRSAKeyPairError))
        })
        
        assert(showCVVResults, equalsTo: [.failure(.missing(.rsaKeyPair))])
    }
    
    func test_showCVV_shouldDeliverErrorOnSessionIDLoadFailure() {
        
        let loadSessionIDError = anyError("SessionID Failure")
        let (sut, _, keyPairLoader, sessionIDLoader, _) = makeSUT()
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .failure(loadSessionIDError))
        })
        
        assert(showCVVResults, equalsTo: [.failure(.missing(.sessionID))])
    }
    
    func test_showCVV_shouldDeliverErrorOnSymmetricKeyLoadFailure() {
        
        let loadSymmetricKeyError = anyError("SymmetricKey Failure")
        let (sut, _, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .failure(loadSymmetricKeyError))
        })
        
        assert(showCVVResults, equalsTo: [.failure(.missing(.symmetricKey))])
    }
    
    func test_showCVV_shouldDeliverErrorOnSigningFailure() {
        
        let signingError = anyError("Signing Failure")
        let (sut, _, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT(
            sign: { _,_ in throw signingError }
        )
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
        })
        
        assert(showCVVResults, equalsTo: [.failure(.makeJSONFailure)])
    }
    
    func test_showCVV_shouldDeliverErrorOnSignatureCreationFailure() {
        
        let signatureCreationError = anyError("Signature Creation Failure")
        let (sut, _, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT(
            createSignature: { _,_ in throw signatureCreationError }
        )
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
        })
        
        assert(showCVVResults, equalsTo: [.failure(.makeJSONFailure)])
    }
    
    func test_showCVV_shouldDeliverErrorOnSignatureVerificationFailure() {
        
        let signatureVerificationError = anyError("Signature Verification Failure")
        let (sut, _, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT(
            verify: { _,_,_ in throw signatureVerificationError }
        )
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
        })
        
        assert(showCVVResults, equalsTo: [.failure(.makeJSONFailure)])
    }
    
    func test_showCVV_shouldDeliverErrorOnAESEncryptionFailure() {
        
        let aesEncryptionError = anyError("AES Encryption Failure")
        let (sut, _, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT(
            aesEncrypt: { _,_ in throw aesEncryptionError }
        )
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
        })
        
        assert(showCVVResults, equalsTo: [.failure(.makeJSONFailure)])
    }
    
    func test_showCVV_shouldDeliverErrorOnServiceProcessFailure() {
        
        let serviceProcessError = anyShowCVVAPIError()
        let (sut, showCVVService, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            showCVVService.complete(with: .failure(serviceProcessError))
        })
        
        assert(showCVVResults, equalsTo: [.failure(.apiError(serviceProcessError))])
    }
    
    func test_showCVV_shouldDeliverErrorOnNonBase64RemoteCVV() {
        
        let remoteCVV = RemoteCVV("123456")
        let (sut, showCVVService, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            showCVVService.complete(with: .success(remoteCVV))
        })
        
        assert(showCVVResults, equalsTo: [.failure(.transcodeFailure)])
    }
    
    func test_showCVV_shouldDeliverErrorOnDecryptionFailure() {
        
        let decryptionError = anyError("Decryption Failure")
        let (sut, showCVVService, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT(
            decrypt: { _,_ in throw decryptionError }
        )
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            showCVVService.complete(with: .success(makeBased64RemoteCVV()))
        })
        
        assert(showCVVResults, equalsTo: [.failure(.transcodeFailure)])
    }
    
    func test_showCVV_shouldDeliverDataToStringConversionErrorOnNonStringRemoteCVV() {
        
        // 0xC3 is a starting byte for a 2-byte UTF-8 encoded character, but 0x28 is not a valid continuation byte.
        let nonStringRemoteCVVData = Data([0xC3, 0x28])
        let (sut, showCVVService, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT(
            decrypt: { _,_ in nonStringRemoteCVVData }
        )
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            showCVVService.complete(with: .success(makeBased64RemoteCVV()))
        })
        
        assert(showCVVResults, equalsTo: [.failure(.transcodeFailure)])
    }
    
    func test_showCVV_shouldDeliverSVVOnSuccess() {
        
        let cvvValue = "a-b-c-"
        let remoteCVV = makeBased64RemoteCVV(cvvValue)
        let (sut, showCVVService, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            showCVVService.complete(with: .success(remoteCVV))
        })
        
        assert(showCVVResults, equalsTo: [.success(.init(cvvValue))])
    }
    
    // MARK: - Helpers
    
    fileprivate typealias SessionID = PublicKeyAuthenticationResponse.SessionID
    private typealias SUT = Composer<SessionID>
    private typealias Crypto = CVVPINCrypto<ECDHPublicKey, ECDHPrivateKey, RSAPublicKey, RSAPrivateKey, SymmetricKey>
    private typealias CVVResult = SUT.CVVService.CVVDomain.Result
    
    private func makeSUT(
        decrypt: Crypto.RSADecrypt? = nil,
        sign: Crypto.Sign? = nil,
        createSignature: Crypto.CreateSignature? = nil,
        verify: Crypto.Verify? = nil,
        aesEncrypt: Crypto.AESEncrypt? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        showCVVService: ShowCVVServiceSpy<SessionID>,
        keyPairLoader: RSAKeyPairLoaderSpy,
        sessionIDLoader: SessionIDLoaderSpy<SessionID>,
        symmetricKeyLoader: SymmetricKeyLoaderSpy
    ) {
        let (infra, _, keyPairLoader, _, sessionIDLoader, _, _, symmetricKeyLoader) = makeCVVPINInfra(SessionID.self, file: file, line: line)
        let (remote, showCVVService, _, _) = makeCVVPRemote(SessionID.self, file: file, line: line)
        let sut = SUT(
            crypto: .test(
                aesEncrypt: aesEncrypt,
                rsaDecrypt: decrypt,
                sign: sign,
                createSignature: createSignature,
                verify: verify
            ),
            infra: infra,
            remote: remote
        )
        
        // TODO: fix this and restore memory leak tracking
        // trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, showCVVService, keyPairLoader, sessionIDLoader, symmetricKeyLoader)
    }
    
    private func showCVVResults(
        _ sut: SUT,
        forCardWithID cardID: CardID = .init(rawValue: 987654321),
        on action: @escaping () -> Void
    ) -> [CVVResult] {
        
        var cvvResults = [CVVResult]()
        let exp = expectation(description: "wait for completion")
        
        let showCVV = sut.showCVV()
        showCVV(cardID) {
            
            cvvResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        return cvvResults
    }
}

private func makeBased64RemoteCVV(
    _ value: String? = nil
) -> RemoteCVV {
    
    let value = value ?? .init(UUID().uuidString.prefix(6))
    let data = Data(value.utf8)
    
    return .init(rawValue: data.base64EncodedString())
}

private func makeSessionID(
    _ rawValue: String = UUID().uuidString
) -> ComposerShowCVVTests.SessionID {
    
    .init(rawValue: rawValue)
}
