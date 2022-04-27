//
//  ServerCommandsAccountControllerTests.swift
//  ForaBankTests
//
//  Created by Андрей Лятовец on 1/20/22.
//

import XCTest
@testable import ForaBank

class ServerCommandsAccountControllerTests: XCTestCase {

	let bundle = Bundle(for: ServerCommandsAccountControllerTests.self)

	let decoder = JSONDecoder.serverDate
	let encoder = JSONEncoder.serverDate
	let formatter = DateFormatter.iso8601

	//MARK: - GetAccountStatementResponseGeneric

	func testGetAccountStatement_Payload_Encoding() throws {

		// given
		let endDate = formatter.date(from: "2022-01-20T16:44:35.147Z")
		let startDate = formatter.date(from: "2022-01-20T16:44:35.147Z")

		let command = ServerCommands.AccountController.GetAccountStatement(token: "",
																		   accountNumber: "string",
																		   endDate: endDate,
																		   id: 0,
																		   name: "string",
																		   startDate: startDate,
																		   statementFormat: .csv)

		let expected = "{\"statementFormat\":\"CSV\",\"id\":0,\"endDate\":\"2022-01-20T16:44:35.147Z\",\"name\":\"string\",\"startDate\":\"2022-01-20T16:44:35.147Z\",\"accountNumber\":\"string\"}"

		// when
		let result = try encoder.encode(command.payload)
		let resultString = String(decoding: result, as: UTF8.self)

		// then
		XCTAssertEqual(resultString, expected)
	}

	func testGetAccountStatement_Response_Decoding() throws {

		// given
		let url = bundle.url(forResource: "GetAccountStatementResponseGeneric", withExtension: "json")!
		let json = try Data(contentsOf: url)
        let date = Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000))

		let accountStatementData = ProductStatementData(mcc: 3245,
														accountId: 10004111477,
														accountNumber: "70601810711002740401",
														amount: 144.21,
														cardTranNumber: "4256901080508437",
														city: "string",
														comment: "Перевод денежных средств. НДС не облагается.",
														country: "string",
														currencyCodeNumeric: 810,
														date: date,
														deviceCode: "string",
														documentAmount: 144.21,
														documentId: 10230444722,
														fastPayment: .init(documentComment: "string",
																		   foreignBankBIC: "044525491",
																		   foreignBankID: "10000001153",
																		   foreignBankName: "КУ ООО ПИР Банк - ГК \\\"АСВ\\\"",
																		   foreignName: "Петров Петр Петрович",
																		   foreignPhoneNumber: "70115110217",
																		   opkcid: "A1355084612564010000057CAFC75755"),
														groupName: "Прочие операции",
														isCancellation: false,
														md5hash: "75f3ee3b2d44e5808f41777c613f23c9",
														merchantName: "DBO MERCHANT FORA, Zubovskiy 2",
														merchantNameRus: "DBO MERCHANT FORA, Zubovskiy 2",
														opCode: 1,
														operationId: "909743",
														operationType: .debit,
														paymentDetailType: .betweenTheir,
														svgImage: .init(description: "string"),
														terminalCode: "41010601",
														tranDate: date,
														type: .inside)

		let expected = ServerCommands.AccountController.GetAccountStatement.Response(statusCode: .ok,
																					 errorMessage: "string",
																					 data: [accountStatementData])

		// when
		let result = try decoder.decode(ServerCommands.AccountController.GetAccountStatement.Response.self, from: json)

		// then
		XCTAssertEqual(result, expected)
	}
	
	func testGetAccountStatement_MinResponse_Decoding() throws {

		// given
		let url = bundle.url(forResource: "GetAccountStatementResponseGenericMin", withExtension: "json")!
		let json = try Data(contentsOf: url)
		let date = Date(timeIntervalSince1970: TimeInterval(1648512000000 / 1000))

		let accountStatementData = ProductStatementData(mcc: nil,
														accountId: nil,
														accountNumber: "70601810711002740401",
														amount: 144.21,
														cardTranNumber: nil,
														city: nil,
														comment: "Перевод денежных средств. НДС не облагается.",
														country: nil,
														currencyCodeNumeric: 810,
														date: date,
														deviceCode: nil,
														documentAmount: nil,
														documentId: nil,
														fastPayment: .init(documentComment: "string",
																		   foreignBankBIC: "044525491",
																		   foreignBankID: "10000001153",
																		   foreignBankName: "КУ ООО ПИР Банк - ГК \\\"АСВ\\\"",
																		   foreignName: "Петров Петр Петрович",
																		   foreignPhoneNumber: "70115110217",
																		   opkcid: "A1355084612564010000057CAFC75755"),
														groupName: "Прочие операции",
														isCancellation: false,
														md5hash: "75f3ee3b2d44e5808f41777c613f23c9",
														merchantName: "DBO MERCHANT FORA, Zubovskiy 2",
														merchantNameRus: nil,
														opCode: nil,
														operationId: nil,
														operationType: .debit,
														paymentDetailType: .betweenTheir,
														svgImage: .init(description: "string"),
														terminalCode: nil,
														tranDate: date,
														type: .inside)

		let expected = ServerCommands.AccountController.GetAccountStatement.Response(statusCode: .ok,
																					 errorMessage: "string",
																					 data: [accountStatementData])

		// when
		let result = try decoder.decode(ServerCommands.AccountController.GetAccountStatement.Response.self, from: json)

		// then
		XCTAssertEqual(result, expected)
	}
	
	

	//MARK: - GetPrintFormForAccountStatement

	func testGetPrintFormForAccountStatement_Payload_Encoding() throws {

		// given
		let endDate = formatter.date(from: "2022-01-20T16:46:58.563Z")
		let startDate = formatter.date(from: "2022-01-20T16:46:58.563Z")

		let command = ServerCommands.AccountController.GetAccountStatement(token: "",
																		   accountNumber: "string",
																		   endDate: endDate,
																		   id: 0,
																		   name: "string",
																		   startDate: startDate,
																		   statementFormat: .csv)

		let expected = "{\"statementFormat\":\"CSV\",\"id\":0,\"endDate\":\"2022-01-20T16:46:58.563Z\",\"name\":\"string\",\"startDate\":\"2022-01-20T16:46:58.563Z\",\"accountNumber\":\"string\"}"
		
		// when
		let result = try encoder.encode(command.payload)
		let resultString = String(decoding: result, as: UTF8.self)
		
		// then
		XCTAssertEqual(resultString, expected)
	}
    
    //MARK: - SaveAccountName

    func testSaveAccountName_Response_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "SaveAccountNameResponseGeneric", withExtension: "json") else {
            XCTFail("testSaveAccountName_Response_Decoding : Missing file: SaveAccountNameResponseGeneric.json")
            return
        }
        let json = try Data(contentsOf: url)
        let expected = ServerCommands.AccountController.SaveAccountName.Response(statusCode: .ok, errorMessage: "string", data: EmptyData())
        
        // when
        let result = try decoder.decode(ServerCommands.AccountController.SaveAccountName.Response.self, from: json)
        
        // then
        XCTAssertEqual(result, expected)
    }
}
