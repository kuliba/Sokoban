//
//  ServerCommandsPushDeviceTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 03.02.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsPushDeviceTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsPushDeviceTests.self)
    let decoder = JSONDecoder.serverDate

    //MARK: - GetNotifications
    
    func testRegisterPushDeviceForUser_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "RegisterPushDeviceForUserResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.PushDeviceController.RegisterPushDeviceForUser.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.PushDeviceController.RegisterPushDeviceForUser.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - InstallPushDevice
    
    func testInstallPushDevice_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "InstallPushDeviceResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.PushDeviceController.InstallPushDevice.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.PushDeviceController.InstallPushDevice.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - UninstallPushDevice
    
    func testUninstallPushDevice_Response_Decoding() throws {

        // given
        let url = bundle.url(forResource: "UninstallPushDeviceResponseGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.PushDeviceController.UninstallPushDevice.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.PushDeviceController.UninstallPushDevice.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
