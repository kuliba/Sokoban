//
//  LiveCVVPINJSONMakerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 02.11.2023.
//

import CryptoKit
@testable import ForaBank
import ForaCrypto
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
        
        XCTAssertNoThrow(
            try JSONDecoder().decode(RequestJSON.self, from: json)
        )
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
        
        try XCTAssertNoThrow(JSONDecoder().decode(SecretJSON.self, from: decrypted))
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
            transportKey: transportKey ?? { try .init(key: ForaCrypto.Crypto.transportKey()) },
            processingKey: processingKey ?? { try .init(key: ForaCrypto.Crypto.processingKey()) },
            log: { message,_,_ in logSpy.log(message) }
        )
        let sut = LiveCVVPINJSONMaker(crypto: crypto)
        
        return (sut, crypto)
    }
    
    private final class LogSpy {
        
        private(set) var messages = [String]()
        
        func log(_ message: String) {
            
            self.messages.append(message)
        }
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
}
