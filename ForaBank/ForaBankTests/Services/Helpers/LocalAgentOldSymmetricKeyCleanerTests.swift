//
//  LocalAgentOldSymmetricKeyCleanerTests.swift
//  VortexTests
//
//  Created by Max Gribov on 26.07.2023.
//

import XCTest
@testable import ForaBank

final class LocalAgentOldSymmetricKeyCleanerTests: XCTestCase {

    typealias SUT = LocalAgentOldSymmetricKeyCleaner<SettingsAgentSpy, KeychainAgentSpy>
    
    //MARK: - Key Cleaned
    
    func test_cleanForNotAppLaunchedBeforeAndKeyStored_keyCleaned()  throws{
        
        let settingData = try makeBoolSettingData(value: false)
        let sampleKeyData = Data(repeating: 5, count: 8)
        let (sut, settingsAgentSpy, keychainAgentSpy) = makeSut(storredSetting: (settingData, .general(.launchedBefore)), storredKeyData: sampleKeyData)
        
        XCTAssertEqual(keychainAgentSpy.storedKeyData, sampleKeyData)
        
        // when
        XCTAssertNoThrow(try sut.clean())
        XCTAssertEqual(settingsAgentSpy.loadAttempts, [.general(.launchedBefore)])
        XCTAssertEqual(keychainAgentSpy.isStorredAttemptsTypes, [[.symmetricKeyCache]])
        XCTAssertEqual(keychainAgentSpy.clearAttemptsTypes, [.symmetricKeyCache])
        
        // then
        XCTAssertNil(keychainAgentSpy.storedKeyData)
    }
    
    // No data for app launched before == app never launched before
    func test_cleanForNoDataAppLaunchedBeforeAndKeyStored_keyCleaned()  throws{
        
        let sampleKeyData = Data(repeating: 5, count: 8)
        let (sut, settingsAgentSpy, keychainAgentSpy) = makeSut(storredKeyData: sampleKeyData)
        
        XCTAssertEqual(keychainAgentSpy.storedKeyData, sampleKeyData)
        
        // when
        XCTAssertNoThrow(try sut.clean())
        XCTAssertEqual(settingsAgentSpy.loadAttempts, [.general(.launchedBefore)])
        XCTAssertEqual(keychainAgentSpy.isStorredAttemptsTypes, [[.symmetricKeyCache]])
        XCTAssertEqual(keychainAgentSpy.clearAttemptsTypes, [.symmetricKeyCache])
        
        // then
        XCTAssertNil(keychainAgentSpy.storedKeyData)
    }
    
    //MARK: - Key Not Cleaned
    
    func test_cleanForAppLaunchedBeforeAndKeyStored_keyNotCleaned() throws {
        
        let settingData = try makeBoolSettingData(value: true)
        let sampleKeyData = Data(repeating: 5, count: 8)
        let (sut, settingsAgentSpy, keychainAgentSpy) = makeSut(storredSetting: (settingData, .general(.launchedBefore)), storredKeyData: sampleKeyData)
        
        XCTAssertEqual(keychainAgentSpy.storedKeyData, sampleKeyData)
        
        // when
        XCTAssertNoThrow(try sut.clean())
        XCTAssertEqual(settingsAgentSpy.loadAttempts, [.general(.launchedBefore)])
        XCTAssertEqual(keychainAgentSpy.isStorredAttemptsTypes, [])
        XCTAssertEqual(keychainAgentSpy.clearAttemptsTypes, [])
        
        // then
        XCTAssertNotNil(keychainAgentSpy.storedKeyData)
    }
    
    func test_cleanForNotAppLaunchedBeforeAndNoKeyStored_noKeyClearAttempts()  throws{
        
        let settingData = try makeBoolSettingData(value: false)
        let (sut, settingsAgentSpy, keychainAgentSpy) = makeSut(storredSetting: (settingData, .general(.launchedBefore)))
        
        XCTAssertNil(keychainAgentSpy.storedKeyData)
        
        // when
        XCTAssertNoThrow(try sut.clean())
        XCTAssertEqual(settingsAgentSpy.loadAttempts, [.general(.launchedBefore)])
        XCTAssertEqual(keychainAgentSpy.isStorredAttemptsTypes, [[.symmetricKeyCache]])
        
        // then
        XCTAssertEqual(keychainAgentSpy.clearAttemptsTypes, [])
    }
            
    func test_cleanForNoDataAppLaunchedBeforeAndNoKeyStored_noKeyClearAttempts()  throws{
        
        let (sut, settingsAgentSpy, keychainAgentSpy) = makeSut()
        
        XCTAssertNil(keychainAgentSpy.storedKeyData)
        
        // when
        XCTAssertNoThrow(try sut.clean())
        XCTAssertEqual(settingsAgentSpy.loadAttempts, [.general(.launchedBefore)])
        XCTAssertEqual(keychainAgentSpy.isStorredAttemptsTypes, [[.symmetricKeyCache]])
        
        // then
        XCTAssertEqual(keychainAgentSpy.clearAttemptsTypes, [])
    }
    
    func makeBoolSettingData(value: Bool) throws -> Data {
        
        try JSONEncoder().encode(value)
    }

    //MARK: - Helpers
    
    func makeSut(
        storredSetting: (Data, SettingType)? = nil,
        storredKeyData: Data? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (SUT, SettingsAgentSpy, KeychainAgentSpy) {
        
        let settingsAgentSpy = SettingsAgentSpy(storred: storredSetting)
        let keychainAgentSpy = KeychainAgentSpy(storedKeyData: storredKeyData, keyValueType: .symmetricKeyCache)
        let sut = LocalAgentOldSymmetricKeyCleaner(settingsAgent: settingsAgentSpy, keychainAgent: keychainAgentSpy)
        trackForMemoryLeaks(settingsAgentSpy, file: file, line: line)
        trackForMemoryLeaks(keychainAgentSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, settingsAgentSpy, keychainAgentSpy)
    }
}

final class SettingsAgentSpy: SettingsAgentProtocol {
    
    private(set) var storeAttempts: [SettingType] = []
    private(set) var loadAttempts: [SettingType] = []
    private(set) var clearAttempts: [SettingType] = []
    
    private(set) var storred: (Data, SettingType)?
    
    
    init(storred: (Data, SettingType)?) {
        
        self.storred = storred
    }
    
    func store<Setting>(_ setting: Setting, type: ForaBank.SettingType) throws where Setting : Decodable, Setting : Encodable {
        
        storeAttempts.append(type)
        let data = try JSONEncoder().encode(setting)
        storred = (data, type)
    }
    
    func load<Setting>(type: ForaBank.SettingType) throws -> Setting where Setting : Decodable, Setting : Encodable {
        
        loadAttempts.append(type)
        guard let (data, storredType) = storred else {
            throw Error.noStoredData
        }
        
        guard storredType == type else {
            throw Error.storedDataTypeMismatch
        }
        
        return try JSONDecoder().decode(Setting.self, from: data)
    }
    
    func clear(type: ForaBank.SettingType) {
        
        clearAttempts.append(type)
        guard let (_, storredType) = storred, storredType == type else {
            return
        }
        
        storred = nil
    }
    
    enum Error: Swift.Error {
        
        case noStoredData
        case storedDataTypeMismatch
    }
}


