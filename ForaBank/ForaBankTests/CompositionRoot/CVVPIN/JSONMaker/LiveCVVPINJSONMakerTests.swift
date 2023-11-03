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
}
