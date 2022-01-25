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
	let formatter = DateFormatter.utc

	//MARK: - GetAccountStatementResponseGeneric

	func testGetAccountStatement_Response_Encoding() throws {

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
		let url = bundle.url(forResource: "AccountControllerResponseGeneric", withExtension: "json")!
		let json = try Data(contentsOf: url)
		let date = formatter.date(from: "2022-01-25T10:32:41.777Z")!
		let tranDate = formatter.date(from: "2022-01-25T10:32:41.777Z")!

		let accountStatementData = ProductStatementData(MCC: 3245,
														accountID: 10004111477,
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
														documentID: 10230444722,
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
														tranDate: tranDate,
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

	func testGetPrintFormForAccountStatement_Response_Encoding() throws {

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
}
