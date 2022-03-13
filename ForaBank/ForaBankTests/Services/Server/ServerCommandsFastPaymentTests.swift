//
//  ServerCommandsFastPaymentTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 01.02.2022.
//

import Foundation

import XCTest
@testable import ForaBank

class ServerCommandsFastPaymentTests: XCTestCase {

    let bundle = Bundle(for: ServerCommandsFastPaymentTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - CreateFastPaymentContract
    
    func testCreateFastPaymentContract_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "CreateFastPaymentContractResponseGeneric", withExtension: "json") else {
            XCTFail("testCreateFastPaymentContract_Response_Decoding : Missing file: CreateFastPaymentContractResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)

        let expected = ServerCommands.FastPaymentController.CreateFastPaymentContract.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.FastPaymentController.CreateFastPaymentContract.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - CreateFastPaymentContract
    
    func testFastPaymentContractFindList_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "FastPaymentContractFindListResponseGeneric", withExtension: "json") else {
            XCTFail("testFastPaymentContractFindList_Response_Decoding : Missing file: FastPaymentContractFindListResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let fastPaymentContractFullInfoType = ServerCommands.FastPaymentController.FastPaymentContractFindList.Response.FastPaymentContractFullInfoType(fastPaymentContractAccountAttributeList: [.init(accountID: 0, accountNumber: "string", flagPossibAddAccount: FastPaymentFlag.empty, maxAddAccount: 0, minAddAccount: 0)], fastPaymentContractAttributeList: [.init(accountID: 0, branchBIC: "string", branchID: 0, clientID: 0, flagBankDefault: FastPaymentFlag.empty, flagClientAgreementIn: FastPaymentFlag.empty, flagClientAgreementOut: FastPaymentFlag.empty, fpcontractID: 0, phoneNumber: "string")], fastPaymentContractClAttributeList: [.init(clientInfo: .init(address: "string", clientID: 0, clientName: "string", clientPatronymicName: "string", clientSurName: "string", docType: "string", inn: "string", name: "string", nm: "string", regNumber: "string", regSeries: "string"))])
        
        let expected = ServerCommands.FastPaymentController.FastPaymentContractFindList.Response(statusCode: .ok, errorMessage: "string", data: [fastPaymentContractFullInfoType])
        
        // when
        let result = try decoder.decode(ServerCommands.FastPaymentController.FastPaymentContractFindList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testFastPaymentContractFindList_Response_Decoding_Min() throws {

        // given
        guard let url = bundle.url(forResource: "FastPaymentContractFindListResponseGenericMin", withExtension: "json") else {
            XCTFail("testFastPaymentContractFindList_Response_Decoding_Min : Missing file: FastPaymentContractFindListResponseGenericMin.json")
            return
        }
        let json = try Data(contentsOf: url)
        let fastPaymentContractFullInfoType = ServerCommands.FastPaymentController.FastPaymentContractFindList.Response.FastPaymentContractFullInfoType(fastPaymentContractAccountAttributeList: [.init(accountID: nil, accountNumber: nil, flagPossibAddAccount: nil, maxAddAccount: nil, minAddAccount: nil)], fastPaymentContractAttributeList: [.init(accountID: nil, branchBIC: nil, branchID: nil, clientID: nil, flagBankDefault: nil, flagClientAgreementIn: nil, flagClientAgreementOut: nil, fpcontractID: nil, phoneNumber: nil)], fastPaymentContractClAttributeList: [.init(clientInfo: nil)])
        
        let expected = ServerCommands.FastPaymentController.FastPaymentContractFindList.Response(statusCode: .ok, errorMessage: "string", data: [fastPaymentContractFullInfoType])
        
        // when
        let result = try decoder.decode(ServerCommands.FastPaymentController.FastPaymentContractFindList.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - UpdateFastPaymentContract
    
    func testUpdateFastPaymentContract_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "UpdateFastPaymentContractResponseGeneric", withExtension: "json") else {
            XCTFail("testUpdateFastPaymentContract_Response_Decoding : Missing file: UpdateFastPaymentContractResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.FastPaymentController.UpdateFastPaymentContract.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.FastPaymentController.UpdateFastPaymentContract.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
