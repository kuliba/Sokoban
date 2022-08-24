//
//  SettingsModelTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 22.08.2022.
//

import XCTest
@testable import ForaBank

class SettingsModelActivateTests: XCTestCase {

    func testSetPushNotification_Reduce() throws {

        // given
        let responseSettings: [UserSettingData] = [.init(name: nil, sysName: "testSettings", value: "testValue")]

        let setting: UserSettingData = .init(name: nil, sysName: UserSettingData.Kind.disablePush.rawValue, value: "0")

        // when

        let result = Model.reduceSettings(userSettings: responseSettings, data: setting )
        let expected: [UserSettingData] = [.init(name: nil, sysName: "testSettings", value: "testValue"), .init(name: nil, sysName: UserSettingData.Kind.disablePush.rawValue, value: "0")]
        
        // then
        XCTAssertEqual(expected, result)
    }
    
    func testSetPushNotificationWithSetting_Reduce() throws {

        // given
        let responseSettings: [UserSettingData] = [.init(name: nil, sysName: "testSettings", value: "testValue"), .init(name: nil, sysName: UserSettingData.Kind.disablePush.rawValue, value: "0")]

        let setting: UserSettingData = .init(name: nil, sysName: UserSettingData.Kind.disablePush.rawValue, value: "1")

        // when

        let result = Model.reduceSettings(userSettings: responseSettings, data: setting)
        let expected: [UserSettingData] = [.init(name: nil, sysName: "testSettings", value: "testValue"), .init(name: nil, sysName: UserSettingData.Kind.disablePush.rawValue, value: "1")]
        
        // then
        XCTAssertEqual(expected, result)
    }
}
