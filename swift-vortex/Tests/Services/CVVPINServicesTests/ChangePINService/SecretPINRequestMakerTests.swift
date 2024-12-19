//
//  SecretPINRequestMakerTests.swift
//  
//
//  Created by Igor Malyarov on 05.10.2023.
//

import CVVPINServices
import XCTest

final class SecretPINRequestMakerTests: XCTestCase {
    
    func test_makeSecretPIN_shouldDeliverErrorOnAESEncryptError() throws {
        
        let aesEncryptError = anyError("AESEncrypt Failure")
        let sut = makeSUT(
            aesEncrypt: { _, _ in throw aesEncryptError }
        )
        
        try XCTAssertThrowsAsNSError(
            sut.makeSecretPIN(),
            error: aesEncryptError
        )
    }
    
    func test_makeSecretPIN_shouldDeliverJSON() throws {
        
        let sessionIDValue = "Session ID 321"
        let pinChangeJSON = Data("secret PIN".utf8)
        let symmetricKey = makeSymmetricKey()
        let sut = makeSUT()
        
        let secretPIN = try sut.makeSecretPIN(
            sessionIDValue: sessionIDValue,
            pinChangeJSON: pinChangeJSON,
            symmetricKey: symmetricKey
        )
        
        let secretPin = try JSONDecoder().decode(SecretPin.self, from: secretPIN)
        let data = try XCTUnwrap(Data(base64Encoded: secretPin.data))
        let decrypted = try _aesDecrypt(data: data, symmetricKey: symmetricKey)
        
        XCTAssertEqual(secretPin.sessionId, sessionIDValue)
        XCTAssertEqual(decrypted, pinChangeJSON)
    }
    
    func test_makePINChangeJSON_shouldDeliverErrorOnProcessingEncryptError() throws {
        
        let procEncryptError = anyError("RSAEncrypt Failure")
        let sut = makeSUT(
            encryptWithProcessingPublicRSAKey: { _ in throw procEncryptError }
        )
        
        try XCTAssertThrowsAsNSError(
            sut.makePINChangeJSON(),
            error: procEncryptError
        )
    }
    
    func test_makePINChangeJSON_shouldDeliverJSON() throws {
        
        let sessionIDValue = "Session ID 321"
        let cardIDValue = 113579
        let otpValue = "=abc12"
        let pinValue = "6543"
        let eventIDValue = "EventID #13"
        let sut = makeSUT()
        
        let json = try sut.makePINChangeJSON(
            sessionIDValue: sessionIDValue,
            cardIDValue: cardIDValue,
            pinValue: pinValue,
            otpValue: otpValue,
            eventIDValue: eventIDValue
        )
        
        let pinChange = try JSONDecoder().decode(PINChange.self, from: json)
        let secretPINData = try XCTUnwrap(Data(base64Encoded: pinChange.secretPIN))
        let signature = try XCTUnwrap(Data(base64Encoded: pinChange.signature))
        
        XCTAssertEqual(pinChange.sessionId, sessionIDValue)
        XCTAssertEqual(pinChange.cardId, cardIDValue)
        XCTAssertEqual(pinChange.otpCode, otpValue)
        XCTAssertEqual(pinChange.eventId, eventIDValue)

        let secretPIN = try XCTUnwrap(String(data: secretPINData, encoding: .utf8))
        XCTAssertEqual(secretPIN, pinValue)
        
        let concat = sessionIDValue + "\(cardIDValue)" + otpValue + eventIDValue + pinChange.secretPIN + "=="
        XCTAssertEqual(String(data: signature, encoding: .utf8), concat)
    }
    
    // MARK: - Helpers
    
    fileprivate typealias SUT = SecretPINRequestMaker<CardID, EventID, OTP, PIN, SessionID, SymmetricKey>
    private typealias Crypto = ChangePINCrypto<SymmetricKey>
    
    private func makeSUT(
        aesEncrypt: SUT.Crypto.AESEncrypt? = nil,
        encryptWithProcessingPublicRSAKey: SUT.Crypto.EncryptWithProcessingPublicRSAKey? = nil,
        sha256Hash: ((String) -> Data)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        
        let crypto = Crypto(
            aesEncrypt: aesEncrypt ?? _aesEncrypt,
            encryptWithProcessingPublicRSAKey: encryptWithProcessingPublicRSAKey ?? _encryptWithProcessingPublicRSAKey,
            sha256Hash: sha256Hash ?? _sha256Hash
        )
        let sut = SUT(crypto: crypto)
        
        return sut
    }
    
    private let aesSuffix: Data = .init("==".utf8)
    
    private func _aesEncrypt(
        data: Data,
        symmetricKey: SymmetricKey
    ) throws -> Data {
        
        var data = data
        data.append(aesSuffix)
        return data
    }
    
    private func _aesDecrypt(
        data: Data,
        symmetricKey: SymmetricKey
    ) throws -> Data {
        
        data.dropLast(aesSuffix.count)
    }
    
    private func _encryptWithProcessingPublicRSAKey(
        data: Data
    ) throws -> Data {
        
        data
    }
    
    private func _rsaDecrypt(
        data: Data,
        rsaPrivateKey: RSAPrivateKey
    ) throws -> Data {
        
        data
    }
    
    private func _sha256Hash(
        string: String
    ) -> Data {
        
        .init("\(string)==".utf8)
    }

    private struct SecretPin: Decodable {
        
        let sessionId: String
        let data: String
    }

    private struct PINChange: Decodable {

        let sessionId: String
        let cardId: Int
        let otpCode: String
        let eventId: String
        let secretPIN: String
        let signature: String
    }
}

private func anyPINChangeJSON() -> Data {
    
    .init("any pin change data".utf8)
}

// MARK: - DSL

private extension SecretPINRequestMakerTests.SUT {
    
    func makeSecretPIN(
        sessionIDValue: String = "Session ID",
        pinChangeJSON: Data = anyPINChangeJSON(),
        symmetricKey: SymmetricKey = makeSymmetricKey()
    ) throws -> Data {
        
        try self.makeSecretPIN(
            sessionID: makeSessionID(sessionIDValue),
            pinChangeJSON: pinChangeJSON,
            symmetricKey: symmetricKey
        )
    }
    
    func makePINChangeJSON(
        sessionIDValue: String = "Session ID 123",
        cardIDValue: Int = 987654321,
        pinValue: String = "4810",
        otpValue: String = "987654",
        eventIDValue: String = "Event ID 321"
    ) throws -> Data {
        
        try self.makePINChangeJSON(
            sessionID: .init(rawValue: sessionIDValue),
            cardID: .init(rawValue: cardIDValue),
            otp: .init(rawValue: otpValue),
            pin: .init(rawValue: pinValue),
            eventID: .init(rawValue: eventIDValue)
        )
    }
}
