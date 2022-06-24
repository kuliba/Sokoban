//
//  ServerCommandsRegistration.swift
//  ForaBankTests
//
//  Created by Дмитрий on 18.01.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsRegistrationTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsRegistrationTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    
    //MARK: - CheckClient
    
    func testCheckClient_Payload_Encoding() throws {
        
        // given
        let command = ServerCommands.RegistrationContoller.CheckClient(token: "", payload: .init(cardNumber: "test", cryptoVersion: "1.0"))
        let expected = "{\"cryptoVersion\":\"1.0\",\"cardNumber\":\"test\"}"
        
        // when
        let result = try encoder.encode(command.payload)
        let resultString = String(decoding: result, as: UTF8.self)
        
        // then
        XCTAssertEqual(resultString, expected)
    }
    
    func testCheckClient_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "CheckClientResponseGeneric", withExtension: "json") else {
            XCTFail("testCheckClient_Response_Decoding : Missing file: CheckClientResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.RegistrationContoller.CheckClient.Response(statusCode: .ok, errorMessage: "string", data: .init(phone: "123456"))
        
        // when
        let result = try decoder.decode(ServerCommands.RegistrationContoller.CheckClient.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - DoRegistration

    /*
    func testDoRegistration_Payload_Encoding() throws {
        
        // given
        let command = ServerCommands.RegistrationContoller.DoRegistration(token: "", payload: .init(cryptoVersion: "1.0", model: "iPhone SE", operationSystem: "IOS", pushDeviceId: "", pushFcmToken: ""))
        let expected = "{\"cryptoVersion\":\"1.0\",\"model\":\"iPhone SE\",\"pushDeviceId\":\"\",\"operationSystem\":\"IOS\",\"pushFcmToken\":\"\"}"
        
        // when
        let result = try encoder.encode(command.payload)
        let resultString = String(decoding: result, as: UTF8.self)
        
        // then
        XCTAssertEqual(resultString, expected)
    }
    */
    
    func testDoRegistration_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "DoRegistrationResponseGeneric", withExtension: "json") else {
            XCTFail("testDoRegistration_Response_Decoding : Missing file: DoRegistrationResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.RegistrationContoller.DoRegistration.Response(statusCode: .ok, errorMessage: "string", data: "string")
        
        // when
        let result = try decoder.decode(ServerCommands.RegistrationContoller.DoRegistration.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetCode

    func testGetCode_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetCodeResponseGeneric", withExtension: "json") else {
            XCTFail("testGetCode_Response_Decoding : Missing file: GetCodeResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.RegistrationContoller.GetCode.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.RegistrationContoller.GetCode.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - SetDeviceSettings
    
    func testSetDeviceSettings_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "SetDeviceSettingsResponseGeneric", withExtension: "json") else {
            XCTFail("testSetDeviceSettings_Response_Decoding : Missing file: SetDeviceSettingsResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.RegistrationContoller.SetDeviceSettings.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.RegistrationContoller.SetDeviceSettings.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - VerifyCode
    
    func testVerifyCode_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "VerifyCodeResponseGeneric", withExtension: "json") else {
            XCTFail("testVerifyCode_Response_Decoding : Missing file: VerifyCodeResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.RegistrationContoller.VerifyCode.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.RegistrationContoller.VerifyCode.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
