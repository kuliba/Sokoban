//
//  ServerCommandsUserTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 01.02.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsUserTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsUserTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - BlockAccount
    
    func testBlockAccount_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "BlockAccountResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.UserController.BlockAccount.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.UserController.BlockAccount.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetUserSettings
    
    func testGetUserSettings_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "GetUserSettingsResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.UserController.GetUserSettings.Response(statusCode: .ok, errorMessage: "string", data: .init(userSettingList: [.init(name: "Фиксированный код для логина", sysName: "FixedLoginCode", value: "111111")]))
        
        // when
        let result = try decoder.decode(ServerCommands.UserController.GetUserSettings.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }

    //MARK: - SetUserSetting
    
    func testSetUserSetting_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "SetUserSettingResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.UserController.SetUserSetting.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.UserController.SetUserSetting.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
