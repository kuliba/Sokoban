//
//  ServerCommandsUtilityTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 19.01.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsUtilityTests: XCTestCase {

    let bundle = Bundle(for: ServerCommandsUtilityTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - Csrf
    
    func testCsrf_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "CsrfResponseGeneric", withExtension: "json") else {
            XCTFail("testCsrf_Response_Decoding : Missing file: CsrfResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let csrfDto = CsrfData(cert: "string", headerName: "string", pk: "string", sign: "string", token: "string")
        let expected = ServerCommands.UtilityController.Csrf.Response(statusCode: .ok, errorMessage: "string", data: csrfDto)
        
        // when
        let result = try decoder.decode(ServerCommands.UtilityController.Csrf.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - getSessionTimeout

    func testGetSessionTimeout_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "GetSessionTimeoutResponseGeneric", withExtension: "json") else {
            XCTFail("testGetSessionTimeout_Response_Decoding : Missing file: GetSessionTimeoutResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.UtilityController.GetSessionTimeout.Response(statusCode: .ok, errorMessage: "string", data: 0)
        
        // when
        let result = try decoder.decode(ServerCommands.UtilityController.GetSessionTimeout.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - keyExchange
    
    func testKeyExchange_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "KeyExchangeResponseGeneric", withExtension: "json") else {
            XCTFail("testKeyExchange_Response_Decoding : Missing file: KeyExchangeResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.UtilityController.KeyExchange.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.UtilityController.KeyExchange.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - isLogin
    
    func testIsLogin_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "IsLoginResponseGeneric", withExtension: "json") else {
            XCTFail("testIsLogin_Response_Decoding : Missing file: IsLoginResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.UtilityController.IsLogin.Response(statusCode: .ok, errorMessage: "string", data: true)
        
        // when
        let result = try decoder.decode(ServerCommands.UtilityController.IsLogin.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }

}
