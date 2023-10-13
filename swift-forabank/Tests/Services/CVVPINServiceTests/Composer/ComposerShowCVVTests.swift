//
//  ComposerShowCVVTests.swift
//  
//
//  Created by Igor Malyarov on 10.10.2023.
//

@testable import CVVPINService
import XCTest

final class ComposerShowCVVTests: MakeComposerInfraTests {
    
    func test_init_shouldNotMessageCollaborators() {
        
        let (_, cvvService, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        XCTAssertEqual(cvvService.callCount, 0)
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
        
        assert(showCVVResults, equalsTo: [.failure(loadRSAKeyPairError)])
    }
    
    func test_showCVV_shouldDeliverErrorOnSessionIDLoadFailure() {
        
        let loadSessionIDError = anyError("SessionID Failure")
        let (sut, _, keyPairLoader, sessionIDLoader, _) = makeSUT()
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .failure(loadSessionIDError))
        })
        
        assert(showCVVResults, equalsTo: [.failure(loadSessionIDError)])
    }
    
    func test_showCVV_shouldDeliverErrorOnSymmetricKeyLoadFailure() {
        
        let loadSymmetricKeyError = anyError("SymmetricKey Failure")
        let (sut, _, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .failure(loadSymmetricKeyError))
        })
        
        assert(showCVVResults, equalsTo: [.failure(loadSymmetricKeyError)])
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
        
        assert(showCVVResults, equalsTo: [.failure(signingError)])
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
        
        assert(showCVVResults, equalsTo: [.failure(signatureCreationError)])
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
        
        assert(showCVVResults, equalsTo: [.failure(signatureVerificationError)])
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
        
        assert(showCVVResults, equalsTo: [.failure(aesEncryptionError)])
    }
    
    func test_showCVV_shouldDeliverErrorOnServiceProcessFailure() {
        
        let serviceProcessError = anyError("ServiceProcess Failure")
        let (sut, cvvService, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            cvvService.complete(with: .failure(serviceProcessError))
        })
        
        assert(showCVVResults, equalsTo: [.failure(serviceProcessError)])
    }
    
    func test_showCVV_shouldDeliverErrorOnNonBase64RemoteCVV() {
        
        let remoteCVV = RemoteCVV("123456")
        let (sut, cvvService, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            cvvService.complete(with: .success(remoteCVV))
        })
        
        assert(showCVVResults, equalsTo: [.failure(SUT.TranscodeError.base64ConversionFailure)])
    }
    
    func test_showCVV_shouldDeliverErrorOnDecryptionFailure() {
        
        let decryptionError = anyError("Decryption Failure")
        let (sut, cvvService, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT(
            decrypt: { _,_ in throw decryptionError }
        )
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            cvvService.complete(with: .success(makeBased64RemoteCVV()))
        })
        
        assert(showCVVResults, equalsTo: [.failure(decryptionError)])
    }
    
    func test_showCVV_shouldDeliverDataToStringConversionErrorOnNonStringRemoteCVV() {
        
        // 0xC3 is a starting byte for a 2-byte UTF-8 encoded character, but 0x28 is not a valid continuation byte.
        let nonStringRemoteCVVData = Data([0xC3, 0x28])
        let (sut, cvvService, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT(
            decrypt: { _,_ in nonStringRemoteCVVData }
        )
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            cvvService.complete(with: .success(makeBased64RemoteCVV()))
        })
        
        assert(showCVVResults, equalsTo: [.failure(SUT.TranscodeError.dataToStringConversionFailure)])
    }
    
    func test_showCVV_shouldDeliverSVVOnSuccess() {
        
        let cvvValue = "a-b-c-"
        let remoteCVV = makeBased64RemoteCVV(cvvValue)
        let (sut, cvvService, keyPairLoader, sessionIDLoader, symmetricKeyLoader) = makeSUT()
        
        let showCVVResults = showCVVResults(sut, on: {
            
            keyPairLoader.complete(with: .success(makeRSAKeyPair()))
            sessionIDLoader.complete(with: .success(makeSessionID()))
            symmetricKeyLoader.complete(with: .success(makeSymmetricKey()))
            cvvService.complete(with: .success(remoteCVV))
        })
        
        assert(showCVVResults, equalsTo: [.success(.init(cvvValue))])
    }
    
    // MARK: - Helpers
    
    fileprivate typealias SessionID = PublicKeyAuthenticationResponse.SessionID
    private typealias SUT = CVVPINComposer<CardID, CVV, ECDHPublicKey, ECDHPrivateKey, EventID, OTP, PIN, RemoteCVV, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
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
        cvvServiceSpy: CVVServiceSpy,
        keyPairLoader: RSAKeyPairLoaderSpy,
        sessionIDLoader: SessionIDLoaderSpy<SessionID>,
        symmetricKeyLoader: SymmetricKeyLoaderSpy
    ) {
        let (infra, cvvService, _, keyPairLoader, _, _, _, sessionIDLoader, _, _, symmetricKeyLoader) = makeCVVPINInfra(SessionID.self, file: file, line: line)
        let sut = SUT(
            crypto: .test(
                aesEncrypt: aesEncrypt,
                rsaDecrypt: decrypt,
                sign: sign,
                createSignature: createSignature,
                verify: verify
            ),
            infra: infra
        )
        
        // TODO: fix this and restore memory leak tracking
        // trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, cvvService, keyPairLoader, sessionIDLoader, symmetricKeyLoader)
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
