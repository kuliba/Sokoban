//
//  ServerCommandsAtmTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 04.04.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsAtmTests: XCTestCase {
    
    let bundle = Bundle(for: ServerCommandsAtmTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - GetAtmList
    
    func testGetAtmList_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetAtmListResponseGeneric", withExtension: "json") else {
            XCTFail("testGetAtmList_Response_Decoding : Missing file: GetAtmListResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let atmListData = ServerCommands.AtmController.GetAtmList.Response.AtmListData(version: 0, list: [.init(id: "10000161875", name: "Банкомат АКБ \"ФОРА-БАНК\" (АО)", type: 0, serviceIdList: [1, 2, 3], metroStationList: [1, 2, 3], region: "Москва", city: "Москва", address: "Ленинградское шоссе, дом 25", schedule: "ежедневно: 09:30 - 20:30", location: "55.828,37.4894", email: "rumyantsevo@forabank.ru", phoneNumber: "(495) 204 4612", action: .insert)])
        
        let expected = ServerCommands.AtmController.GetAtmList.Response(statusCode: .ok, errorMessage: "string", data: atmListData)
        
        // when
        let result = try decoder.decode(ServerCommands.AtmController.GetAtmList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetAtmList_Response_Server_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetAtmListResponseServer", withExtension: "json") else {
            XCTFail("testGetAtmList_Response_Server_Decoding : Missing file: GetAtmListResponseServer.json")
            return
        }
        
        // then
        XCTAssertNoThrow(try decoder.decode(ServerCommands.AtmController.GetAtmList.Response.self, from: Data(contentsOf: url)))
    }
    
    func testGetAtmList_Parameters() throws {
        
        // given
        let version = 123
        
        // when
        let command = ServerCommands.AtmController.GetAtmList(version: version)
        
        // then
        XCTAssertNotNil(command.parameters)
        XCTAssertEqual(command.parameters?.count, 1)
        
        XCTAssertEqual(command.parameters?[0].name, "version")
        XCTAssertEqual(command.parameters?[0].value, "\(version)")
    }
    
    //MARK: - GetAtmServiceList
    
    func testGetAtmServiceList_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetAtmServiceListResponseGeneric", withExtension: "json") else {
            XCTFail("testGetAtmServiceList_Response_Decoding : Missing file: GetAtmServiceListResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let atmServiceListData = ServerCommands.AtmController.GetAtmServiceList.Response.AtmServiceListData(serial: "bea36075a58954199a6b8980549f6b69", list: [.init(id: 0, name: "string", type: .service)])
        
        let expected = ServerCommands.AtmController.GetAtmServiceList.Response(statusCode: .ok, errorMessage: "string", data: atmServiceListData)
        
        // when
        let result = try decoder.decode(ServerCommands.AtmController.GetAtmServiceList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetAtmServiceList_Response_Server_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetAtmServiceListResponseServer", withExtension: "json") else {
            XCTFail("testGetAtmServiceList_Response_Server_Decoding : Missing file: GetAtmServiceListResponseServer.json")
            return
        }
        
        // then
        XCTAssertNoThrow(try decoder.decode(ServerCommands.AtmController.GetAtmServiceList.Response.self, from: Data(contentsOf: url)))
    }
    
    func testGetAtmServiceList_Parameters() throws {
        
        // given
        let serial = UUID().uuidString
        
        // when
        let command = ServerCommands.AtmController.GetAtmServiceList(serial: serial)
        
        // then
        XCTAssertNotNil(command.parameters)
        XCTAssertEqual(command.parameters?.count, 1)
        
        XCTAssertEqual(command.parameters?[0].name, "serial")
        XCTAssertEqual(command.parameters?[0].value, serial)
    }
    
    
    //MARK: - GetAtmTypeList
    
    func testGetAtmTypeList_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetAtmTypeListResponseGeneric", withExtension: "json") else {
            XCTFail("testGetAtmTypeList_Response_Decoding : Missing file: GetAtmTypeListResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let atmTypeListData = ServerCommands.AtmController.GetAtmTypeList.Response.AtmTypeListData(serial: "bea36075a58954199a6b8980549f6b69", list: [.init(id: 0, name: "string")])
        
        let expected = ServerCommands.AtmController.GetAtmTypeList.Response(statusCode: .ok, errorMessage: "string", data: atmTypeListData)
        
        // when
        let result = try decoder.decode(ServerCommands.AtmController.GetAtmTypeList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetAtmTypeList_Response_Server_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetAtmTypeListResponseServer", withExtension: "json") else {
            XCTFail("testGetAtmTypeList_Response_Server_Decoding : Missing file: GetAtmTypeListResponseServer.json")
            return
        }
        
        // then
        XCTAssertNoThrow(try decoder.decode(ServerCommands.AtmController.GetAtmTypeList.Response.self, from: Data(contentsOf: url)))
    }
    
    func testGetAtmTypeList_Parameters() throws {
        
        // given
        let serial = UUID().uuidString
        
        // when
        let command = ServerCommands.AtmController.GetAtmTypeList(serial: serial)
        
        // then
        XCTAssertNotNil(command.parameters)
        XCTAssertEqual(command.parameters?.count, 1)
        
        XCTAssertEqual(command.parameters?[0].name, "serial")
        XCTAssertEqual(command.parameters?[0].value, serial)
    }
    
    //MARK: - GetAtmMetroStationList
    
    func testGetAtmMetroStationList_Response_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetAtmMetroStationListResponseGeneric", withExtension: "json") else {
            XCTFail("testGetAtmMetroStationList_Response_Decoding : Missing file: GetAtmMetroStationListResponseGeneric.json")
            return
        }
        
        let json = try Data(contentsOf: url)
        let atmMetroStationListData = ServerCommands.AtmController.GetMetroStationList.Response.AtmMetroStationListData(serial: "bea36075a58954199a6b8980549f6b69", list: [.init(id: 0, name: "string", lineName: "string", region: "string", city: "string", color: ColorData(description: "string"))])
        
        let expected = ServerCommands.AtmController.GetMetroStationList.Response(statusCode: .ok, errorMessage: "string", data: atmMetroStationListData)
        
        // when
        let result = try decoder.decode(ServerCommands.AtmController.GetMetroStationList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetAtmMetroStationList_Response_Server_Decoding() throws {
        
        // given
        guard let url = bundle.url(forResource: "GetAtmMetroStationListResponseServer", withExtension: "json") else {
            XCTFail("testGetAtmMetroStationList_Response_Server_Decoding : Missing file: GetAtmMetroStationListResponseServer.json")
            return
        }
        
        // then
        XCTAssertNoThrow(try decoder.decode(ServerCommands.AtmController.GetMetroStationList.Response.self, from: Data(contentsOf: url)))
    }
    
    func testGetAtmMetroStationList_Parameters() throws {
        
        // given
        let serial = UUID().uuidString
        
        // when
        let command = ServerCommands.AtmController.GetMetroStationList(serial: serial)
        
        // then
        XCTAssertNotNil(command.parameters)
        XCTAssertEqual(command.parameters?.count, 1)
        
        XCTAssertEqual(command.parameters?[0].name, "serial")
        XCTAssertEqual(command.parameters?[0].value, serial)
    }
}
