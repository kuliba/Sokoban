////
////  Services+publicKeyTransferServiceTests.swift
////  VortexTests
////
////  Created by Igor Malyarov on 07.09.2023.
////
//
//import CryptoKit
//import CvvPin
//@testable import ForaBank
//import VortexCrypto
//import TransferPublicKey
//import XCTest
//
//final class Services_publicKeyTransferServiceTests: XCTestCase {
//
//    // MARK: - transfer
//
//    func test_transfer_shouldSetURLPath_bindPublicKeyWithEventID() throws {
//
//        let (request, _) = try request()
//
//        let path = try XCTUnwrap(request.url?.lastPathComponent)
//
//        XCTAssertEqual(path, "bindPublicKeyWithEventId")
//    }
//
//    func test_transfer_shouldSetEventFieldOfInSecretJSON() throws {
//
//        let eventID = "event_123"
//        let (request, _) = try request(eventID: eventID)
//        let extractedEventID = try extractSecretJSON(fromRequest: request).eventID
//
//        XCTAssertNoDiff(extractedEventID, eventID)
//    }
//
//    func test_transfer_shouldSetDataFieldOfSecretJSON() throws {
//
//        let (privateKey, publicKey) = try createRandomSecKeys()
//        let (request, sharedSecret) = try request(transportKey: { publicKey })
//        let (_, json) = try extractSecretJSON(fromRequest: request)
//        let (procClientSecretOTPData, clientPublicKeyRSAData) = try decryptProcClientJSON(from: json, with: sharedSecret)
//
//
//        let clientSecretOTP = try VortexCrypto.Crypto.rsaDecrypt(
//            data: procClientSecretOTPData,
//            withPrivateKey: privateKey,
//            algorithm: .rsaEncryptionRaw
//        )
//
//        let clientPublicKeyRSA = try Crypto.createSecKeyWith(
//            data: clientPublicKeyRSAData
//        )
//
//        XCTAssertFalse(clientSecretOTP.isEmpty)
//        XCTAssertFalse(try clientPublicKeyRSA.rawRepresentation.isEmpty)
//    }
//
//    // MARK: - Helpers
//
//    private typealias SharedSecret = KeyTransferService<Services.TransferOTP, Services.ExchangeEventID>.SharedSecret
//
//    private func makeSUT(
//        transportKey: @escaping () throws -> SecKey = VortexCrypto.Crypto.transportKey,
//        file: StaticString = #file,
//        line: UInt = #line
//    ) throws -> (
//        sut: Services.PublicKeyTransferService,
//        spy: HTTPClientSpy
//    ) {
//        let httpClient = HTTPClientSpy()
//        let sut = Services.publicSecKeyTransferService(
//            httpClient: httpClient,
//            transportKey: transportKey
//        )
//
//        trackForMemoryLeaks(httpClient, file: file, line: line)
//        trackForMemoryLeaks(sut, file: file, line: line)
//
//        return (sut, httpClient)
//    }
//
//    private func anySharedSecret() throws -> SharedSecret {
//
//        let password = AES256CBC.randomData(length: 256)
//        let keyData = try AES256CBC.createKey(password: password)
//
//        return .init(keyData)
//    }
//
//    private func request(
//        transportKey: @escaping () throws -> SecKey = VortexCrypto.Crypto.transportKey,
//        otp: String = "abc123",
//        eventID: String = "event_1",
//        file: StaticString = #file,
//        line: UInt = #line
//    ) throws -> (
//        request: URLRequest,
//        sharedSecret: SharedSecret
//    ) {
//        let (sut, spy) = try makeSUT(
//            transportKey: transportKey,
//            file: file, line: line
//        )
//        let sharedSecret = try anySharedSecret()
//        let exp = expectation(description: "wait for completion")
//        var results = [KeyTransferDomain.Result]()
//
//        sut.transfer(
//            otp: .init(value: otp),
//            eventID: .init(value: eventID),
//            sharedSecret: sharedSecret
//        ) { result in
//
//            results.append(result)
//            exp.fulfill()
//        }
//        spy.complete(with: .success((.init(), anyHTTPURLResponse())))
//
//        wait(for: [exp], timeout: 1.0)
//
//        XCTAssertNoDiff(spy.requests.count, 1, file: file, line: line)
//        let request = try XCTUnwrap(spy.requests.first, file: file, line: line)
//
//        return (request, sharedSecret)
//    }
//
//    private func extractSecretJSON(
//        fromRequest request: URLRequest,
//        file: StaticString = #file,
//        line: UInt = #line
//    ) throws -> (
//        eventID: String,
//        json: Data
//    ) {
//        let data = try XCTUnwrap(request.httpBody, file: file, line: line)
//        let secretJSON = try JSONDecoder().decode(SecretJSON.self, from: data)
//
//        let json = try XCTUnwrap(Data(base64Encoded: secretJSON.data), file: file, line: line)
//
//        return (secretJSON.eventId, json)
//    }
//
//    private struct SecretJSON: Decodable {
//        let eventId: String
//        let data: String
//    }
//
//    private func decryptProcClientJSON(
//        from encrypted: Data,
//        with sharedSecret: SharedSecret,
//        file: StaticString = #file,
//        line: UInt = #line
//    ) throws -> (
//        procClientSecretOTP: Data,
//        clientPublicKeyRSA: Data
//    ) {
//        let aes256CBC = try VortexCrypto.AES256CBC(key: sharedSecret.data)
//        let decrypted = try aes256CBC.decrypt(encrypted)
//
//        let procClient = try JSONDecoder().decode(ProcClient.self, from: decrypted)
//
//        let procClientSecretOTP = try XCTUnwrap(
//            Data(base64Encoded: procClient.procClientSecretOTP),
//            file: file, line: line
//        )
//        let clientPublicKeyRSA = try XCTUnwrap(
//            Data(base64Encoded: procClient.clientPublicKeyRSA),
//            file: file, line: line
//        )
//
//        return (procClientSecretOTP, clientPublicKeyRSA)
//    }
//
//    private struct ProcClient: Decodable {
//
//        let procClientSecretOTP: String
//        let clientPublicKeyRSA: String
//    }
//
//    // MARK: - SecKey
//
//    func test_createRandomSecKeys_shouldCreatePublicKey() throws {
//
//        let (_, publicKey) = try createRandomSecKeys()
//
//        try expectAttributes(ofPublicSecKey: publicKey)
//    }
//
//    private func createRandomSecKeys() throws -> (
//        privateKey: SecKey,
//        publicKey: SecKey
//    ) {
//        try Crypto.createRandomSecKeys(
//            keyType: kSecAttrKeyTypeRSA,
//            keySizeInBits: 4096
//        )
//    }
//
//    // MARK: - transport key
//
//    func test_transportKey() throws {
//
//        let key = try VortexCrypto.Crypto.transportKey()
//
//        try expectAttributes(ofPublicSecKey: key)
//    }
//
//    private func expectAttributes(
//        ofPublicSecKey key: SecKey,
//        file: StaticString = #file,
//        line: UInt = #line
//    ) throws {
//
//        XCTAssertTrue(SecKeyGetTypeID() == CFGetTypeID(key), file: file, line: line)
//
//        let attributes = try XCTUnwrap(
//            SecKeyCopyAttributes(key) as? [String: Any],
//            file: file, line: line
//        )
//
//        let keyClass = try XCTUnwrap(
//            attributes[kSecAttrKeyClass as String],
//            file: file, line: line
//        )
//        XCTAssertEqual(keyClass as! CFString, kSecAttrKeyClassPublic, file: file, line: line)
//
//        let keySize = try XCTUnwrap(
//            attributes[kSecAttrKeySizeInBits as String] as? Int,
//            file: file, line: line
//        )
//        XCTAssertEqual(keySize, 4_096, file: file, line: line)
//
//        let keyType = try XCTUnwrap(
//            attributes[kSecAttrKeyType as String] as? String,
//            file: file, line: line
//        )
//        XCTAssertEqual(keyType, kSecAttrKeyTypeRSA as String, file: file, line: line)
//
//        let effectiveSize = try XCTUnwrap(
//            attributes[kSecAttrEffectiveKeySize as String] as? Int,
//            file: file, line: line
//        )
//        XCTAssertEqual(effectiveSize, 4_096, file: file, line: line)
//
//        let canEncrypt = try XCTUnwrap(
//            attributes[kSecAttrCanEncrypt as String] as? Bool,
//            file: file, line: line
//        )
//        XCTAssertTrue(canEncrypt, file: file, line: line)
//
//        let canDecrypt = try XCTUnwrap(
//            attributes[kSecAttrCanDecrypt as String] as? Bool,
//            file: file, line: line
//        )
//        XCTAssertTrue(canDecrypt, file: file, line: line)
//
//        let canDerive = try XCTUnwrap(
//            attributes[kSecAttrCanDerive as String] as? Bool,
//            file: file, line: line
//        )
//        XCTAssertFalse(canDerive, file: file, line: line)
//    }
//}
