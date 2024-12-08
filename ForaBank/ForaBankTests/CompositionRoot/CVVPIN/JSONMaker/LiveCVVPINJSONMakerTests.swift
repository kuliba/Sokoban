//
//  LiveCVVPINJSONMakerTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 02.11.2023.
//

import CryptoKit
import class CVVPIN_Services.ChangePINService
import class CVVPIN_Services.ShowCVVService
@testable import ForaBank
import VortexCrypto
import XCTest

final class LiveCVVPINJSONMakerTests: XCTestCase {
    
    func test_makeRequestJSON_shouldMakeJSONWithCorrectStructure() throws {
        
        let (sut, crypto) = makeSUT()
        let publicKey = crypto.generateECDHKeyPair().publicKey
        let rsaKeyPair = try crypto.generateRSA4096BitKeyPair()
        
        let json = try sut.makeRequestJSON(
            publicKey: publicKey,
            rsaKeyPair: rsaKeyPair
        )
        
        try XCTAssertNoThrow(json.decode(as: RequestJSON.self))
    }
    
    func test_makeSecretJSON_shouldMakeJSONWithCorrectStructure() throws {
        
        let (sut, _) = makeSUT()
        let sessionKey = anySessionKey()
        
        let (encrypted, _) = try sut.makeSecretJSON(
            otp: "987654",
            sessionKey: sessionKey
        )
        
        let decrypted = try aesDecrypt(
            data: encrypted,
            sessionKey: sessionKey
        )
        
        try XCTAssertNoThrow(decrypted.decode(as: SecretJSON.self))
    }
    
    func test_makeSecretRequestJSON_shouldMakeJSONWithCorrectStructure() throws {
        
        let crypto = makeSUT().crypto
        let transportKeyPair = try crypto.generateRSA4096BitKeyPair()
        let (sut, _) = makeSUT(transportKey: { .init(key: transportKeyPair.publicKey.key) })
        let publicKey = crypto.generateECDHKeyPair().publicKey
        
        let encrypted = try sut.makeSecretRequestJSON(
            publicKey: publicKey
        )
        
        let decrypted = try VortexCrypto.Crypto.rsaDecrypt(
            data: encrypted,
            withPrivateKey: transportKeyPair.privateKey.key,
            algorithm: .rsaEncryptionPKCS1
        )
        
        try XCTAssertNoThrow(decrypted.decode(as: SecretRequestJSON.self))
    }
    
    func test_makePINChangeJSON_shouldMakeJSONWithCorrectStructure() throws {
        
        let (sut, crypto) = makeSUT()
        let sessionKey = anySessionKey()
        let rsaKeyPair = try crypto.generateRSA4096BitKeyPair()
        
        let encrypted = try sut.makePINChangeJSON(
            sessionID: anySessionID(),
            cardID: anyCardID(),
            otp: anyOTP(),
            pin: anyPIN(),
            otpEventID: anyOTPEventID(),
            sessionKey: sessionKey,
            rsaPrivateKey: rsaKeyPair.privateKey
        )
        
        let decrypted = try aesDecrypt(
            data: encrypted,
            sessionKey: sessionKey
        )
        
        try XCTAssertNoThrow(decrypted.decode(as: PINChangeJSON.self))
    }
    
    func test_makeShowCVVSecretJSON_shouldMakeJSONWithCorrectStructure() throws {
        
        let (sut, crypto) = makeSUT()
        let sessionKey = anySessionKey()
        let rsaKeyPair = try crypto.generateRSA4096BitKeyPair()
        
        let encrypted = try sut.makeShowCVVSecretJSON(
            with: anyCardID(),
            and: anySessionID(),
            rsaKeyPair: rsaKeyPair,
            sessionKey: sessionKey
        )
        
        let decrypted = try aesDecrypt(
            data: encrypted,
            sessionKey: sessionKey
        )
        
        try XCTAssertNoThrow(decrypted.decode(as: ShowCVVSecretJSON.self))
    }
    
    // MARK: - Helpers
    
    typealias TransportKey = LiveExtraLoggingCVVPINCrypto.TransportKey
    typealias ProcessingKey = LiveExtraLoggingCVVPINCrypto.ProcessingKey
    typealias GetTransportKey = () throws -> TransportKey
    typealias GetProcessingKey = () throws -> ProcessingKey
    
    private func makeSUT(
        transportKey: GetTransportKey? = nil,
        processingKey: GetProcessingKey? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        jsonMaker: LiveCVVPINJSONMaker,
        crypto: LiveExtraLoggingCVVPINCrypto
    ) {
        let logSpy = LogSpy()
        let crypto = LiveExtraLoggingCVVPINCrypto(
            transportKey: transportKey ?? { try .init(key: VortexCrypto.Crypto.transportKey()) },
            processingKey: processingKey ?? { try .init(key: VortexCrypto.Crypto.processingKey()) },
            log: { message,_,_ in logSpy.log(message) }
        )
        let sut = LiveCVVPINJSONMaker(crypto: crypto)
        
        return (sut, crypto)
    }
    
    private struct RequestJSON: Decodable {
        
        let clientPublicKeyRSA: Data
        let publicApplicationSessionKey: Data
        let signature: Data
        
        init(
            clientPublicKeyRSA: String,
            publicApplicationSessionKey: String,
            signature: String
        ) throws {
            
            guard
                let clientPublicKeyRSA = Data(base64Encoded: clientPublicKeyRSA),
                let publicApplicationSessionKey = Data(base64Encoded: publicApplicationSessionKey),
                let signature = Data(base64Encoded: signature)
            else {
                throw Base64EncodingError()
            }
            
            self.clientPublicKeyRSA = clientPublicKeyRSA
            self.publicApplicationSessionKey = publicApplicationSessionKey
            self.signature = signature
        }
    }
    
    private struct Base64EncodingError: Error {}
    
    private func anySessionKey() -> SessionKey {
        
        .init(sessionKeyValue: anyData(bitCount: 256))
    }
    
    func aesDecrypt(
        data: Data,
        sessionKey: SessionKey
    ) throws -> Data {
        
        let prefix32 = sessionKey.sessionKeyValue.prefix(32)
        let aes256CBC = try AES256CBC(key: prefix32)
        let encrypted = try aes256CBC.decrypt(data)
        
        return encrypted
    }
    
    private struct SecretJSON: Decodable {
        
        let procClientSecretOTP: Data
        let clientPublicKeyRSA: Data
        
        init(
            procClientSecretOTP: String,
            clientPublicKeyRSA: String
        ) throws {
            
            guard
                let clientPublicKeyRSA = Data(base64Encoded: clientPublicKeyRSA),
                let procClientSecretOTP = Data(base64Encoded: procClientSecretOTP)
            else {
                throw Base64EncodingError()
            }
            
            self.clientPublicKeyRSA = clientPublicKeyRSA
            self.procClientSecretOTP = procClientSecretOTP
        }
    }
    
    private struct SecretRequestJSON: Decodable {
        
        let publicApplicationSessionKey: Data
        
        init(
            publicApplicationSessionKey: String
        ) throws {
            
            guard
                let publicApplicationSessionKey = Data(base64Encoded: publicApplicationSessionKey)
            else {
                throw Base64EncodingError()
            }
            
            self.publicApplicationSessionKey = publicApplicationSessionKey
        }
    }
    
    private struct PINChangeJSON: Decodable {
        
        let sessionId: String
        let cardId: String
        let otpCode: String
        let eventId: String
        let secretPIN: Data
        let signature: Data
        
        init(
            sessionId: String,
            cardId: String,
            otpCode: String,
            eventId: String,
            secretPIN: Data,
            signature: Data
        ) throws {
            
            guard
                let secretPIN = Data(base64Encoded: secretPIN),
                let signature = Data(base64Encoded: signature)
            else {
                throw Base64EncodingError()
            }
            
            self.sessionId = sessionId
            self.cardId = cardId
            self.otpCode = otpCode
            self.eventId = eventId
            self.secretPIN = secretPIN
            self.signature = signature
        }
    }
    
    private struct ShowCVVSecretJSON: Decodable {
        
        let cardId: String
        let sessionId: String
        let signature: Data
        
        init(
            cardId: String,
            sessionId: String,
            signature: String
        ) throws {
            
            guard
                let signature = Data(base64Encoded: signature)
            else {
                throw Base64EncodingError()
            }
            
            self.cardId = cardId
            self.sessionId = sessionId
            self.signature = signature
        }
    }
}

private extension Data {
    
    func decode<T: Decodable>(as type: T.Type) throws -> T {
        
        try JSONDecoder().decode(type.self, from: self)
    }
}
