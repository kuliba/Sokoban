//
//  ServerCommandsCardTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 20.01.2022.
//

import XCTest
@testable import ForaBank

class ServerCommandsCardTests: XCTestCase {

    let bundle = Bundle(for: ServerCommandsCardTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    let formatter = DateFormatter.iso8601

    //MARK: - BlockCard
    
    func testBlockCard_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "BlockCardResponseGeneric", withExtension: "json") else {
            XCTFail("testBlockCard_Response_Decoding : Missing file: BlockCardResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.CardController.BlockCard.Response(statusCode: .ok, errorMessage: "string", data: .init(statusBrief: "string", statusDescription: "string"))
        
        // when
        let result = try decoder.decode(ServerCommands.CardController.BlockCard.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testBlockCard_Response_Decoding_Min() throws {

        // given
        guard let url = bundle.url(forResource: "BlockCardResponseGenericMin", withExtension: "json") else {
            XCTFail("testBlockCard_Response_Decoding_Min : Missing file: BlockCardResponseGenericMin.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.CardController.BlockCard.Response(statusCode: .ok, errorMessage: "string", data: .init(statusBrief: nil, statusDescription: nil))
        
        // when
        let result = try decoder.decode(ServerCommands.CardController.BlockCard.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetCardStatement
    
    func testGetCardStatement_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "GetCardStatementResponseGeneric", withExtension: "json") else {
            XCTFail("testGetCardStatement_Response_Decoding : Missing file: GetCardStatementResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let date = Date.dateUTC(with: 1648512000000)

        let productStatementData = ProductStatementData(mcc: 3245, accountId: 10004111477, accountNumber: "70601810711002740401", amount: 144.21, cardTranNumber: "4256901080508437", city: "string", comment: "Перевод денежных средств. НДС не облагается.", country: "string", currencyCodeNumeric: 810, date: date, deviceCode: "string", documentAmount: 144.21, documentId: 10230444722, fastPayment: .init(documentComment: "string", foreignBankBIC: "044525491", foreignBankID: "10000001153", foreignBankName: "КУ ООО ПИР Банк - ГК \\\"АСВ\\\"", foreignName: "Петров Петр Петрович", foreignPhoneNumber: "70115110217", opkcid: "A1355084612564010000057CAFC75755", operTypeFP: "string", tradeName: "string", guid: "string"), groupName: "Прочие операции", isCancellation: false, md5hash: "75f3ee3b2d44e5808f41777c613f23c9", merchantName: "DBO MERCHANT FORA, Zubovskiy 2", merchantNameRus: "DBO MERCHANT FORA, Zubovskiy 2", opCode: 1, operationId: "909743", operationType: .debit, paymentDetailType: .betweenTheir, svgImage: .init(description: "string"), terminalCode: "41010601", tranDate: date, type: OperationEnvironment.inside)
        let expected = ServerCommands.CardController.GetCardStatement.Response(statusCode: .ok, errorMessage: "string", data: [productStatementData])
        
        // when
        let result = try decoder.decode(ServerCommands.CardController.GetCardStatement.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    func testGetCardStatement_Response_Decoding_Min() throws {

        // given
        guard let url = bundle.url(forResource: "GetCardStatementResponseGenericMin", withExtension: "json") else {
            XCTFail("testGetCardStatement_Response_Decoding_Min : Missing file: GetCardStatementResponseGenericMin.json")
            return
        }
        let json = try Data(contentsOf: url)
        let date = Date.dateUTC(with: 1648512000000)
        let productStatementData = ProductStatementData(mcc: nil, accountId: nil, accountNumber: "70601810711002740401", amount: 144.21, cardTranNumber: nil, city: nil, comment: "Перевод денежных средств. НДС не облагается.", country: nil, currencyCodeNumeric: 810, date: date, deviceCode: nil, documentAmount: nil, documentId: nil, fastPayment: nil, groupName: "Прочие операции", isCancellation: nil, md5hash: "75f3ee3b2d44e5808f41777c613f23c9", merchantName: nil, merchantNameRus: nil, opCode: nil, operationId: "123", operationType: .debit, paymentDetailType: .betweenTheir, svgImage: nil, terminalCode: nil, tranDate: nil, type: OperationEnvironment.inside)
        let expected = ServerCommands.CardController.GetCardStatement.Response(statusCode: .ok, errorMessage: "string", data: [productStatementData])
        
        // when
        let result = try decoder.decode(ServerCommands.CardController.GetCardStatement.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - GetOwnerPhoneNumber

    func testGetOwnerPhoneNumber_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "GetOwnerPhoneNumberResponseGeneric", withExtension: "json") else {
            XCTFail("testGetOwnerPhoneNumber_Response_Decoding : Missing file: GetOwnerPhoneNumberResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.CardController.GetOwnerPhoneNumber.Response(statusCode: .ok, errorMessage: "string", data: "string")
        
        // when
        let result = try decoder.decode(ServerCommands.CardController.GetOwnerPhoneNumber.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - SaveCardName

    func testSaveCardName_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "SaveCardNameResponseGeneric", withExtension: "json") else {
            XCTFail("testSaveCardName_Response_Decoding : Missing file: SaveCardNameResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.CardController.SaveCardName.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.CardController.SaveCardName.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
    
    //MARK: - UnblockCard

    func testUnblockCard_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "UnblockCardResponseGeneric", withExtension: "json") else {
            XCTFail("UnblockCard_Response_Decoding : Missing file: UnblockCardResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.CardController.UnblockCard.Response(statusCode: .ok, errorMessage: "string", data: .init(statusBrief: "string", statusDescription: "string"))
        
        // when
        let result = try decoder.decode(ServerCommands.CardController.UnblockCard.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
