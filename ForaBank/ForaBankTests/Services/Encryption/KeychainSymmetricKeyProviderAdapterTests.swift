//
//  KeychainSymmetricKeyProviderAdapterTests.swift
//  VortexTests
//
//  Created by Max Gribov on 21.07.2023.
//

import XCTest
@testable import ForaBank
import SymmetricEncryption

final class KeychainSymmetricKeyProviderAdapterTests: XCTestCase {
    
    typealias SUT = KeychainSymmetricKeyProviderAdapter<KeychainAgentSpy, KeyProviderSpy>

    func test_init_resultEmptyData() {
        
        let (sut, _, _) = makeSut()
        
        let result = sut.getSymmetricKeyRawRepresentation()
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_initWithEmptyStoredKeyData_oneLoadKeyDataAttempt_thenReturnKeyDataFromKeyProvider_thenOneStoreKeyDataAttempt() {
        
        let sampleKeyData = Data(repeating: 5, count: 10)
        let (sut, keychainAgentSpy, _) = makeSut(sampleKeyData: sampleKeyData)
        
        let result = sut.getSymmetricKeyRawRepresentation()
        
        XCTAssertEqual(keychainAgentSpy.loadAttemptsTypes, [.symmetricKeyCache])
        XCTAssertEqual(result, sampleKeyData)
    }
    
    func test_initWithEmptyStoredKeyData_returnKeyDataFromKeyProvider() {
        
        let sampleKeyData = Data(repeating: 5, count: 10)
        let (sut, _, keyProviderSpy) = makeSut(sampleKeyData: sampleKeyData)
        
        let result = sut.getSymmetricKeyRawRepresentation()
        
        XCTAssertEqual(keyProviderSpy.getSymmetricKeyRawRepresentationAttempts, 1)
        XCTAssertEqual(result, sampleKeyData)
    }
    
    func test_initWithEmptyStoredKeyData_oneStoreKeyDataAttempt() {
        
        let sampleKeyData = Data(repeating: 5, count: 10)
        let (sut, keychainAgentSpy, _) = makeSut(sampleKeyData: sampleKeyData)
        
        let result = sut.getSymmetricKeyRawRepresentation()
        
        XCTAssertEqual(keychainAgentSpy.storeAttemptsTypes, [.symmetricKeyCache])
        XCTAssertEqual(result, sampleKeyData)
    }
    
    func test_initWithStoredKeyData_resultLoadedKeyData_noKeyProviderAttempts_noStoreKeyDataAttempts() {
        
        let storedKeyData = Data(repeating: 5, count: 10)
        let (sut, keychainAgentSpy, keyProviderSpy) = makeSut(storedKeyData: storedKeyData)
        
        let result = sut.getSymmetricKeyRawRepresentation()
        
        XCTAssertEqual(keychainAgentSpy.loadAttemptsTypes, [.symmetricKeyCache])
        XCTAssertEqual(keyProviderSpy.getSymmetricKeyRawRepresentationAttempts, 0)
        XCTAssertEqual(keychainAgentSpy.storeAttemptsTypes, [])
        XCTAssertEqual(result, storedKeyData)
    }
    
    func test_initWithEmptyStoredKeyData_secondGetSymmetricKeyRawRepresentationRequest_resultFromKeychainStore() {
        
        let sampleKeyData = Data(repeating: 5, count: 10)
        let (sut, keychainAgentSpy, keyProviderSpy) = makeSut(sampleKeyData: sampleKeyData)
        
        let _ = sut.getSymmetricKeyRawRepresentation()
        let secondResult = sut.getSymmetricKeyRawRepresentation()
        
        XCTAssertEqual(keychainAgentSpy.loadAttemptsTypes, [.symmetricKeyCache, .symmetricKeyCache])
        XCTAssertEqual(keyProviderSpy.getSymmetricKeyRawRepresentationAttempts, 1)
        XCTAssertEqual(keychainAgentSpy.storeAttemptsTypes, [.symmetricKeyCache])
        XCTAssertEqual(secondResult, sampleKeyData)
    }
    
    //MARK: - Helpers
    
    func makeSut(storedKeyData: Data? = nil,
                 sampleKeyData: Data? = nil,
                 file: StaticString = #file,
                 line: UInt = #line) -> (SUT, KeychainAgentSpy, KeyProviderSpy) {
        
        let keyValueType = KeychainValueType.symmetricKeyCache
        let keychainAgentSpy = KeychainAgentSpy(storedKeyData: storedKeyData, keyValueType: keyValueType)
        let keyProviderSpy = KeyProviderSpy(sampleKeyData: sampleKeyData)
        
        let sut = SUT(keychainAgent: keychainAgentSpy, keyProvider: keyProviderSpy, keychainValueType: keyValueType)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(keychainAgentSpy, file: file, line: line)
        trackForMemoryLeaks(keyProviderSpy, file: file, line: line)
        
        return (sut, keychainAgentSpy, keyProviderSpy)
    }
}

final class KeyProviderSpy: SymmetricKeyProviderProtocol {
    
    let sampleKeyData: Data?
    private(set) var getSymmetricKeyRawRepresentationAttempts = 0
    
    init(sampleKeyData: Data?) {
        
        self.sampleKeyData = sampleKeyData
    }
    
    func getSymmetricKeyRawRepresentation() -> Data {
        
        getSymmetricKeyRawRepresentationAttempts += 1
        
        return sampleKeyData ?? Data()
    }
}
