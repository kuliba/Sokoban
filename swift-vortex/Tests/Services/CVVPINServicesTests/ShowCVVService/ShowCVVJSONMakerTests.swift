//
//  ShowCVVJSONMakerTests.swift
//  
//
//  Created by Igor Malyarov on 03.10.2023.
//

import CVVPINServices
import XCTest

final class ShowCVVJSONMakerTests: XCTestCase {
    
    func test_makeJSON_shouldThrowOnHashSignVerifyFailure() throws {
        
        let hashSignVerifyError = anyError("HashSignVerify Failure")
        let sut = makeSUT(
            hashSignVerify: { _,_,_ in throw hashSignVerifyError },
            aesEncrypt: { data, _ in data }
        )
        
        try XCTAssertThrowsAsNSError(
            sut.makeSecretJSON(),
            error: hashSignVerifyError
        )
    }
    
    func test_makeJSON_shouldThrowOnAESEncryptFailure() throws {
        
        let aesEncryptError = anyError("AESEncrypt Failure")
        let sut = makeSUT(
            hashSignVerify: { string, _, _ in Data(string.utf8) },
            aesEncrypt: { _,_ in throw aesEncryptError }
        )
        
        try XCTAssertThrowsAsNSError(
            sut.makeSecretJSON(),
            error: aesEncryptError
        )
    }
    
    func test_makeJSON_shouldNotThrowOnNonThrowingHashSignVerifyAndAESEncrypt() throws {
        
        let sut = makeSUT(
            hashSignVerify: { string, _, _ in Data(string.utf8) },
            aesEncrypt: { data, _ in data }
        )
        
        try XCTAssertNoThrow(sut.makeSecretJSON())
    }
    
    func test_makeJSON_shouldWrapInJSONTwice_onAESIdentity() throws {
        
        let sut = makeSUT(
            hashSignVerify: { string, _, _ in Data(string.utf8) },
            aesEncrypt: { data, _ in data }
        )
        
        let secretJSON = try sut.makeSecretJSON(789_654, "Session 123")
        
        try assert(secretJSON, cardID: 789_654, sessionId: "Session 123") { $0 }
    }
    
    func test_makeJSON_shouldUseAESEncryptionClosure() throws {
        
        let suffix = "===="
        let sut = makeSUT(
            hashSignVerify: { string, _, _ in Data(string.utf8) },
            aesEncrypt: { data, key in
                
                var data = data
                data.append(.init(suffix.utf8))
                return data
            }
        )
        
        let secretJSON = try sut.makeSecretJSON(789_654, "Session 123")
        
        try assert(secretJSON, cardID: 789_654, sessionId: "Session 123") {
            
            $0.dropLast(suffix.utf8.count)
        }
    }
    
    // MARK: - Helpers
    
    typealias SUT = ShowCVVJSONMaker<CardID, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey>
    
    private func makeSUT(
        hashSignVerify: @escaping SUT.HashSignVerify,
        aesEncrypt: @escaping SUT.AESEncrypt,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        return .init(
            hashSignVerify: hashSignVerify,
            aesEncrypt: aesEncrypt
        )
    }
    
    private func assert(
        _ secretJSON: Data,
        cardID expectedCardID: Int,
        sessionId: String,
        aesDecrypt: @escaping (Data) throws -> Data,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let secretJSON = try JSONDecoder().decode(SecretJSON.self, from: secretJSON)
        let data = try XCTUnwrap(Data(base64Encoded: secretJSON.data), file: file, line: line)
        let decrypted = try aesDecrypt(data)
        let json = try JSONDecoder().decode(JSON.self, from: decrypted)
        let cardID = try XCTUnwrap(Int(json.cardId), file: file, line: line)
        
        XCTAssertEqual(cardID, expectedCardID, file: file, line: line)
        XCTAssertEqual(secretJSON.sessionId, sessionId, file: file, line: line)
        XCTAssertEqual(json.sessionId, sessionId, file: file, line: line)
        
        let signedData = try XCTUnwrap(Data(base64Encoded: json.signature), file: file, line: line)
        XCTAssertEqual(
            String(data: signedData, encoding: .utf8),
            "\(expectedCardID)\(sessionId)",
            file: file, line: line
        )
    }
    
    private struct SecretJSON: Decodable, Equatable {
        
        let sessionId: String
        let data: String
    }
    
    private struct JSON: Decodable, Equatable {
        
        let cardId: String
        let sessionId: String
        let signature: String
    }
}

// MARK: - DSL

private extension ShowCVVJSONMaker<CardID, RSAPublicKey, RSAPrivateKey, SessionID, SymmetricKey> {
    
    func makeSecretJSON(
        _ cardIDValue: Int = 123_456,
        _ sessionIDValue: String = UUID().uuidString,
        keyPair: (publicKey: RSAPublicKey, privateKey: RSAPrivateKey) = makeRSAKeyPair(),
        symmetricKey: SymmetricKey = makeSymmetricKey()
    ) throws -> Data {
        
        try makeSecretJSON(
            with: .init(rawValue: cardIDValue),
            and: .init(rawValue: sessionIDValue),
            publicKey: keyPair.publicKey,
            privateKey: keyPair.privateKey,
            symmetricKey: symmetricKey
        )
    }
}
