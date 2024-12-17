//
//  ServerCommandsConsentTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 20.01.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsConsentTests: XCTestCase {

    let bundle = Bundle(for: ServerCommandsConsentTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    //MARK: - ChangeClientConsentMe2MePull
    
    func testChangeClientConsentMe2MePull_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "ChangeClientConsentMe2MePullResponseGeneric", withExtension: "json") else {
            XCTFail("testChangeClientConsentMe2MePull_Response_Decoding : Missing file: ChangeClientConsentMe2MePullResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.ConsentController.ChangeClientConsentMe2MePull.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.ConsentController.ChangeClientConsentMe2MePull.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - CreateIsOneTimeConsentMe2MePull
    
    func testCreateIsOneTimeConsentMe2MePull_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "CreateIsOneTimeConsentMe2MePullResponseGeneric", withExtension: "json") else {
            XCTFail("testCreateIsOneTimeConsentMe2MePull_Response_Decoding : Missing file: CreateIsOneTimeConsentMe2MePullResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.ConsentController.CreateIsOneTimeConsentMe2MePull.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.ConsentController.CreateIsOneTimeConsentMe2MePull.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }

    //MARK: - CreatePermanentConsentMe2MePull
    
    func testCreatePermanentConsentMe2MePull_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "CreatePermanentConsentMe2MePullResponseGeneric", withExtension: "json") else {
            XCTFail("testCreatePermanentConsentMe2MePull_Response_Decoding : Missing file: CreatePermanentConsentMe2MePullResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.ConsentController.CreatePermanentConsentMe2MePull.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.ConsentController.CreatePermanentConsentMe2MePull.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetClientConsentMe2MePull
    
    func testGetClientConsentMe2MePull_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "GetClientConsentMe2MePullResponseGeneric", withExtension: "json") else {
            XCTFail("testGetClientConsentMe2MePull_Response_Decoding : Missing file: GetClientConsentMe2MePullResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let consentMe2MePullData = ConsentMe2MePullData(active: true, bankId: "1crt88888881", beginDate: "01.01.2022 00:00:00", consentId: 1, endDate: "01.01.2022 00:00:00", oneTimeConsent: true)
        let expected = ServerCommands.ConsentController.GetClientConsentMe2MePull.Response(statusCode: .ok, errorMessage: "string", data: .init(consentList: [consentMe2MePullData]))
        
        // when
        let result = try decoder.decode(ServerCommands.ConsentController.GetClientConsentMe2MePull.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetClientConsentMe2MePull_Response_Decoding_Min() throws {

        // given
        guard let url = bundle.url(forResource: "GetClientConsentMe2MePullResponseGenericMin", withExtension: "json") else {
            XCTFail("testGetClientConsentMe2MePull_Response_Decoding_Min : Missing file: GetClientConsentMe2MePullResponseGenericMin.json")
            return
        }
        let json = try Data(contentsOf: url)
        let consentMe2MePullData = ConsentMe2MePullData(active: nil, bankId: "1crt88888881", beginDate: "01.01.2022 00:00:00", consentId: 1, endDate: "01.01.2022 00:00:00", oneTimeConsent: nil)
        let expected = ServerCommands.ConsentController.GetClientConsentMe2MePull.Response(statusCode: .ok, errorMessage: "string", data: .init(consentList: [consentMe2MePullData]))
        
        // when
        let result = try decoder.decode(ServerCommands.ConsentController.GetClientConsentMe2MePull.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetMe2MeDebitConsent
    
    func testGetMe2MeDebitConsent_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "GetMe2MeDebitConsentResponseGeneric", withExtension: "json") else {
            XCTFail("testGetMe2MeDebitConsent_Response_Decoding : Missing file: GetMe2MeDebitConsentResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let me2MeDebitConsentData = ConsentMe2MeDebitData(accountId: 10000184511, amount: 100, bankRecipientID: "string", cardId: 10000184511, fee: 10, rcvrMsgId: "string", recipientID: "string", refTrnId: "string")
        let expected = ServerCommands.ConsentController.GetMe2MeDebitConsent.Response(statusCode: .ok, errorMessage: "string", data: me2MeDebitConsentData)
        
        // when
        let result = try decoder.decode(ServerCommands.ConsentController.GetMe2MeDebitConsent.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetMe2MeDebitConsent_Response_Decoding_Min() throws {

        // given
        guard let url = bundle.url(forResource: "GetMe2MeDebitConsentResponseGenericMin", withExtension: "json") else {
            XCTFail("testGetMe2MeDebitConsent_Response_Decoding_Min : Missing file: GetMe2MeDebitConsentResponseGenericMin.json")
            return
        }
        let json = try Data(contentsOf: url)
        let me2MeDebitConsentData = ConsentMe2MeDebitData(accountId: 10000184511, amount: 100, bankRecipientID: "string", cardId: 10000184511, fee: 10, rcvrMsgId: nil, recipientID: nil, refTrnId: nil)
        let expected = ServerCommands.ConsentController.GetMe2MeDebitConsent.Response(statusCode: .ok, errorMessage: "string", data: me2MeDebitConsentData)
        
        // when
        let result = try decoder.decode(ServerCommands.ConsentController.GetMe2MeDebitConsent.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
