//
//  SecretRequestCryptographerTests.swift
//  
//
//  Created by Igor Malyarov on 18.07.2023.
//

import CryptoKit
import CvvPin
import XCTest

final class SecretRequestCryptographerTests: XCTestCase {
    
    // MARK: - makeSecretRequest
    
    func test_makeSecretRequest_identityEncryption() throws {
        
        let (saS, paS) = try SecretRequestCryptographer.makeECDHKeys()
        let sut = makeSUT(
            makeECDHKeys: { (saS, paS) },
            publicTransportKeyEncrypt: { $0 }
        )
        let sessionCode = uniqueCryptoSessionCode()
        let expectedData = try SecretRequestCryptographer.wrap(paS, andEncrypt: { $0 })
        
        expect(sut, with: sessionCode, toMakeSecretRequestResults: [.success(.init(code: sessionCode, data: expectedData))])
    }
    
    func test_makeSecretRequest_shouldCompleteWithErrorOnMakeECDHKeysError() throws {
        
        let makeECDHKeysError = anyNSError(domain: "ECDHKeysError")
        let sut = makeSUT(
            makeECDHKeys: { throw makeECDHKeysError },
            publicTransportKeyEncrypt: { $0 }
        )
        let sessionCode = uniqueCryptoSessionCode()
        
        expect(sut, with: sessionCode, toMakeSecretRequestResults: [.failure(makeECDHKeysError)])
    }
    
    func test_makeSecretRequest_shouldCompleteWithErrorOnEncryptionError() throws {
        
        let encryptionError = anyNSError(domain: "ECDHKeysError")
        let sut = makeSUT(
            publicTransportKeyEncrypt: { _ in throw encryptionError }
        )
        let sessionCode = uniqueCryptoSessionCode()
        
        expect(sut, with: sessionCode, toMakeSecretRequestResults: [.failure(encryptionError)])
    }
    
    // MARK: - wrapAndEncrypt
    
    func test_wrapAndEncrypt_shouldEncryptSerialised() throws {
        
        let paS = try testPaS()
        let data = try SecretRequestCryptographer.wrap(paS, andEncrypt: { $0 })
        
        // expect decode & decrypt
        let identityDecrypter = Decrypter()
        let decrypted = try identityDecrypter.unwrap(data)
        
        XCTAssertEqual(paS.rawRepresentation, decrypted)
    }
    
    func test_wrapAndEncrypt_shouldThrowOnEncryptionError() throws {
        
        let paS = try testPaS()
        let encryptionError = anyNSError(domain: "Encryption")
        let encrypt: (Data) throws -> Data = { _ in
            throw encryptionError
        }
        
        XCTAssertThrowsError(
            try SecretRequestCryptographer.wrap(paS, andEncrypt: encrypt)
        ) {
            XCTAssertEqual($0 as NSError, encryptionError)
        }
    }
    
    // MARK: - makeECDHKeys
    
    func test_makeECDHKeys_shouldCreateKeyForSigningAndVerification() throws {
        
        let (saS, paS) = try SecretRequestCryptographer.makeECDHKeys()
        
        let dataToSign = "Some sample Data to sign.".data(using: .utf8)!
        let signature = try saS.key.signature(for: dataToSign)
        
        XCTAssertTrue(paS.key.isValidSignature(signature, for: dataToSign))
    }
    
    func test_makeECDHKeys_shouldFormPrivatePublicKeyPair() throws {
        
        let (saS, paS) = try SecretRequestCryptographer.makeECDHKeys()
        
        XCTAssertNoDiff(
            saS.key.publicKey.rawRepresentation,
            paS.key.rawRepresentation
        )
    }
    
    // MARK: - P384
    
    func test_P384_shouldHaveRawRepresentation() throws {
        
        let string = String.paSTestStringValue
        let data = try XCTUnwrap(Data(base64Encoded: string))
        let publicKey = try P384.Signing.PublicKey(rawRepresentation: data)
        
        XCTAssertEqual(publicKey.rawRepresentation, data)
    }
    
    func test_P384_shouldHaveBase64RawRepresentation() throws {
        
        let string = String.paSTestStringValue
        let data = try XCTUnwrap(Data(base64Encoded: string))
        let publicKey = try P384.Signing.PublicKey(rawRepresentation: data)
        let raw = publicKey.rawRepresentation
        let base64 = raw.base64EncodedString()
        
        XCTAssertEqual(base64, string)
    }
    
    // MARK: - PaS
    
    func test_PaS_shouldHaveRawRepresentation() throws {
        
        let string = String.paSTestStringValue
        let data = try XCTUnwrap(Data(base64Encoded: string))
        let paS = try SecretRequestCryptographer.PaS(key: .init(rawRepresentation: data))
        
        XCTAssertEqual(paS.rawRepresentation, data)
    }
    
    func test_PaS_shouldHaveBase64RawRepresentation() throws {
        
        let paS = try testPaS()
        let base64 = paS.rawRepresentation.base64EncodedString()
        
        XCTAssertEqual(base64, .paSTestStringValue)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        makeECDHKeys: @escaping SecretRequestCryptographer.MakeECDHKeys = SecretRequestCryptographer.makeECDHKeys,
        publicTransportKeyEncrypt: @escaping SecretRequestCryptographer.Encrypt,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SecretRequestCrypto {
        
        let sut = SecretRequestCryptographer(
            makeECDHKeys: makeECDHKeys,
            encrypt: publicTransportKeyEncrypt
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private final class Decrypter {
        
        typealias Decrypt = (Data) throws -> Data
        
        private let decrypt: Decrypt
        
        init(with decrypt: @escaping Decrypt = { $0 }) {
            
            self.decrypt = decrypt
        }
        
        func decrypt(data: Data) throws -> Data {
            
            let decrypted = try decrypt(data)
            return try unwrap(decrypted)
        }
        
        func unwrap(_ data: Data) throws -> Data {
            
            let decoder = JSONDecoder()
            struct J: Decodable {
                let publicApplicationSessionKey: String
            }
            let j = try decoder.decode(J.self, from: data)
            let key = j.publicApplicationSessionKey
            let data = Data(base64Encoded: key, options: [.ignoreUnknownCharacters])
            
            return try XCTUnwrap(data)
        }
    }
    
    private func testPaS() throws -> SecretRequestCryptographer.PaS {
        
        let string = String.paSTestStringValue
        let data = try XCTUnwrap(Data(base64Encoded: string))
        return try SecretRequestCryptographer.PaS(key: .init(rawRepresentation: data))
    }
    
    private func uniqueCryptoSessionCode() -> CryptoSessionCode {
        
        .init(value: UUID().uuidString)
    }
    
    private func expect(
        _ sut: SecretRequestCrypto,
        with cryptoSessionCode: CryptoSessionCode,
        toMakeSecretRequestResults expectedResults: [SecretRequestCrypto.Result],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var secretRequestResults = [SecretRequestCrypto.Result]()
        let exp = expectation(description: "wait for secret request results")
        
        sut.makeSecretRequest(sessionCode: cryptoSessionCode) {
            secretRequestResults.append($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(secretRequestResults.count, expectedResults.count, "Expected \(expectedResults.count) results, got \(secretRequestResults.count) instead.", file: file, line: line)
        
        zip(secretRequestResults, expectedResults)
            .enumerated().forEach { index, element in
                
                switch element {
                case let (.failure(received as NSError?), .failure(expected as NSError?)):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                case let (.success(received), .success(expected)):
                    XCTAssertNoDiff(received, expected, file: file, line: line)
                    
                default:
                    XCTFail("Expected \(element.1), got \(element.0) instead.", file: file, line: line)
                }
            }
    }
}

private extension SecretRequestCryptographer.PaS {
    
}

private extension String {
    
    static let paSTestStringValue = """
    ZUeC8wZj6yWn6eNBYRtnhVSvffTsQjPTw9MYL3pcQnZDWOuajovDLWDtI9X28YRkcEAwav/160rmytKDmlKMOuUetB2Bqwvnu0YzkVJaQCGJmXehlt1ahEZU3aiug6Wm
    """
}
