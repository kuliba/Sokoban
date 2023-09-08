//
//  Services+publicKeyTransferServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.09.2023.
//

import CryptoKit
import CvvPin
@testable import ForaBank
import ForaCrypto
import TransferPublicKey
import XCTest

final class Services_publicKeyTransferServiceTests: XCTestCase {
    
    func test_transfer_shouldSetURLPath_bindPublicKeyWithEventID() throws {
        
        let (request, _) = try request()

        let path = try XCTUnwrap(request.url?.lastPathComponent)
        
        XCTAssertEqual(path, "bindPublicKeyWithEventId")
    }
    
    func test_transfer_shouldSetEventFieldOfInSecretJSON() throws {
        
        let eventID = "event_123"
        let (request, _) = try request(eventID: eventID)
        let extractedEventID = try extractSecretJSON(fromRequest: request).eventID

        XCTAssertNoDiff(extractedEventID, eventID)
    }
    
    func test_transfer_shouldSetDataFieldOfSecretJSON() throws {
        
        let (request, sharedSecret) = try request()
        let (_, json) = try extractSecretJSON(fromRequest: request)
        let (procClientSecretOTP, clientPublicKeyRSA) = try decryptProcClientJSON(from: json, with: sharedSecret)

        //????
        XCTAssertFalse(procClientSecretOTP.isEmpty)
        XCTAssertFalse(clientPublicKeyRSA.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SharedSecret = KeyTransferService<Services.TransferOTP, Services.ExchangeEventID>.SharedSecret
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> (
        sut: Services.PublicKeyTransferService,
        spy: HTTPClientSpy
    ) {
        let httpClient = HTTPClientSpy()
        let sut = Services.publicSecKeyTransferService(httpClient: httpClient)

        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, httpClient)
    }
    
    private func anySharedSecret() throws -> SharedSecret {
        
        let password = AES256CBC.randomData(length: 256)
        let keyData = try AES256CBC.createKey(password: password)
        
        return .init(keyData)
    }
    
    private func request(
        otp: String = "abc123",
        eventID: String = "event_1",
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> (
        request: URLRequest,
        sharedSecret: SharedSecret
    ) {
        let (sut, spy) = try makeSUT(file: file, line: line)
        let sharedSecret = try anySharedSecret()
        let exp = expectation(description: "wait for completion")
        var results = [KeyTransferDomain.Result]()
        
        sut.transfer(
            otp: .init(value: otp),
            eventID: .init(value: eventID),
            sharedSecret: sharedSecret
        ) { result in
            
            results.append(result)
            exp.fulfill()
        }
        spy.complete(with: .success((.init(), anyHTTPURLResponse())))
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(spy.requests.count, 1, file: file, line: line)
        let request = try XCTUnwrap(spy.requests.first, file: file, line: line)
        
        return (request, sharedSecret)
    }
    
    private func extractSecretJSON(
        fromRequest request: URLRequest,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> (
        eventID: String,
        json: Data
    ) {
        let data = try XCTUnwrap(request.httpBody, file: file, line: line)
        let secretJSON = try JSONDecoder().decode(SecretJSON.self, from: data)
        
        let json = try XCTUnwrap(Data(base64Encoded: secretJSON.data), file: file, line: line)
        
        return (secretJSON.eventId, json)
    }
    
    private struct SecretJSON: Decodable {
        let eventId: String
        let data: String
    }
    
    private func decryptProcClientJSON(
        from encrypted: Data,
        with sharedSecret: SharedSecret,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> (
        procClientSecretOTP: Data,
        clientPublicKeyRSA: Data
    ) {
        let aes256CBC = try ForaCrypto.AES256CBC(key: sharedSecret.data)
        let decrypted = try aes256CBC.decrypt(encrypted)
       
        let procClient = try JSONDecoder().decode(ProcClient.self, from: decrypted)
        
        let procClientSecretOTP = try XCTUnwrap(
            Data(base64Encoded: procClient.procClientSecretOTP),
            file: file, line: line
        )
        let clientPublicKeyRSA = try XCTUnwrap(
            Data(base64Encoded: procClient.clientPublicKeyRSA),
            file: file, line: line
        )
        
        return (procClientSecretOTP, clientPublicKeyRSA)
    }
    
    private struct ProcClient: Decodable {
        
        let procClientSecretOTP: String
        let clientPublicKeyRSA: String
    }
}
