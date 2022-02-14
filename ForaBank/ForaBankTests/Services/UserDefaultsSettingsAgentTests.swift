//
//  UserDefaultsSettingsAgentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 14.02.2022.
//

import XCTest
@testable import ForaBank

class UserDefaultsSettingsAgentTests: XCTestCase {
    
    let settingsAgent = UserDefaultsSettingsAgent(defaults: UserDefaults(suiteName: "TestDefaults")!)

    func testSetting_Store() throws {
    
        // given
        let setting: Bool = false
        
        // then
        XCTAssertNoThrow(try settingsAgent.store(setting, type: .security(.sensor)))
    }

    func testSetting_Load() throws {
    
        // given
        let setting: Bool = false
        
        // when
        try settingsAgent.store(setting, type: .security(.sensor))
        let result: Bool? = try settingsAgent.load(type: .security(.sensor))
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, setting)
    }
    
    func testSetting_Remove() throws {
    
        // given
        let setting: Bool = false
        
        // when
        try settingsAgent.store(setting, type: .security(.sensor))
        settingsAgent.clear(type: .security(.sensor))
        let result: Bool? = try settingsAgent.load(type: .security(.sensor))
        
        // then
        XCTAssertNil(result)
    }
}

