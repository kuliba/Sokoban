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
	
	let decoder = JSONDecoder()
	let encoder = JSONEncoder()
	
	//MARK: - GetAccountStatementResponseGeneric
	
	func testGetAccountStatement_Response_Encoding() throws {
		
		// given
		let command = ServerCommands.AccountController.GetAccountStatement(token: "",
																		   payload: .init(accountNumber: "string",
																						  endDate: "2022-01-20T16:44:35.147Z",
																						  id: 0,
																						  name: "string",
																						  startDate: "2022-01-20T16:44:35.147Z",
																						  statementFormat: .csv))
		
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
		
		let fastPaymentData = FastPaymentData(documentComment: "string",
											  foreignBankBIC: "044525491",
											  foreignBankID: "10000001153",
											  foreignBankName: "КУ ООО ПИР Банк - ГК \\\"АСВ\\\"",
											  foreignName: "Петров Петр Петрович",
											  foreignPhoneNumber: "70115110217",
											  opkcid: "A1355084612564010000057CAFC75755")
		
		let accountStatement = ProductStatementData(MCC: 3245,
													accountID: 10004111477,
													accountNumber: "70601810711002740401",
													amount: 144.21,
													cardTranNumber: "4256901080508437",
													city: "string",
													comment: "Перевод денежных средств. НДС не облагается.",
													country: "string",
													currencyCodeNumeric: 810,
													date: "2022-01-20T11:20:38.488Z",
													deviceCode: "string",
													documentAmount: 144.21,
													documentID: 10230444722,
													fastPayment: fastPaymentData,
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
													tranDate: "2022-01-20T11:20:38.488Z",
													type: .inside)
		
		let expected = ServerCommands.AccountController.GetAccountStatement.Response(statusCode: .ok,
																					 errorMessage: "string",
																					 data: [accountStatement])
		
		// when
		let result = try decoder.decode(ServerCommands.AccountController.GetAccountStatement.Response.self, from: json)
		
		// then
		XCTAssertEqual(result, expected)
	}
	
	
	//MARK: - GetAccountStatementForPeriod
	
	func testGetAccountStatementForPeriod_Response_Encoding() throws {
		
		// given
		let command = ServerCommands.AccountController.GetAccountStatementForPeriod(token: "",
																					payload: .init(accountNumber: "string",
																								   endDate: "2022-01-20T16:44:35.160Z",
																								   id: 0,
																								   name: "string",
																								   startDate: "2022-01-20T16:44:35.160Z",
																								   statementFormat: .csv))
		
		let expected = "{\"statementFormat\":\"CSV\",\"id\":0,\"endDate\":\"2022-01-20T16:44:35.160Z\",\"name\":\"string\",\"startDate\":\"2022-01-20T16:44:35.160Z\",\"accountNumber\":\"string\"}"
		
		// when
		let result = try encoder.encode(command.payload)
		let resultString = String(decoding: result, as: UTF8.self)
		
		// then
		XCTAssertEqual(resultString, expected)
	}
	
	func testGetAccountStatementForPeriod_Response_Decoding() throws {
		
		// given
		let url = bundle.url(forResource: "AccountControllerResponseGeneric", withExtension: "json")!
		let json = try Data(contentsOf: url)
		
		let fastPaymentData = FastPaymentData(documentComment: "string",
											  foreignBankBIC: "044525491",
											  foreignBankID: "10000001153",
											  foreignBankName: "КУ ООО ПИР Банк - ГК \\\"АСВ\\\"",
											  foreignName: "Петров Петр Петрович",
											  foreignPhoneNumber: "70115110217",
											  opkcid: "A1355084612564010000057CAFC75755")
		
		let accountStatement = ProductStatementData(MCC: 3245,
													accountID: 10004111477,
													accountNumber: "70601810711002740401",
													amount: 144.21,
													cardTranNumber: "4256901080508437",
													city: "string",
													comment: "Перевод денежных средств. НДС не облагается.",
													country: "string",
													currencyCodeNumeric: 810,
													date: "2022-01-20T11:20:38.488Z",
													deviceCode: "string",
													documentAmount: 144.21,
													documentID: 10230444722,
													fastPayment: fastPaymentData,
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
													tranDate: "2022-01-20T11:20:38.488Z",
													type: .inside)
		
		let expected = ServerCommands.AccountController.GetAccountStatementForPeriod.Response(statusCode: .ok,
																							  errorMessage: "string",
																							  data: [accountStatement])
		
		// when
		let result = try decoder.decode(ServerCommands.AccountController.GetAccountStatementForPeriod.Response.self, from: json)
		
		// then
		XCTAssertEqual(result, expected)
	}
	
	//MARK: - GetPrintFormForAccountStatement
	
	func testGetPrintFormForAccountStatement_Response_Encoding() throws {
		
		// given
		let command = ServerCommands.AccountController.GetPrintMapForAccountStatement(token: "",
																					  payload: .init(accountNumber: "string",
																									 endDate: "2022-01-20T16:46:58.563Z",
																									 id: 0,
																									 name: "string",
																									 startDate: "2022-01-20T16:46:58.563Z",
																									 statementFormat: .csv))
		
		let expected = "{\"statementFormat\":\"CSV\",\"id\":0,\"endDate\":\"2022-01-20T16:46:58.563Z\",\"name\":\"string\",\"startDate\":\"2022-01-20T16:46:58.563Z\",\"accountNumber\":\"string\"}"
		
		// when
		let result = try encoder.encode(command.payload)
		let resultString = String(decoding: result, as: UTF8.self)
		
		// then
		XCTAssertEqual(resultString, expected)
		
	}
	
	
	//MARK: - GetPrintMapForAccountStatement
	
	func testGetPrintMapForAccountStatement_Response_Encoding() throws {
		
		// given
		let command = ServerCommands.AccountController.GetPrintMapForAccountStatement(token: "",
																					  payload: .init(accountNumber: "string",
																									 endDate: "2022-01-20T16:46:58.569Z",
																									 id: 0,
																									 name: "string",
																									 startDate: "2022-01-20T16:46:58.569Z",
																									 statementFormat: .csv))
		
		let expected = "{\"statementFormat\":\"CSV\",\"id\":0,\"endDate\":\"2022-01-20T16:46:58.569Z\",\"name\":\"string\",\"startDate\":\"2022-01-20T16:46:58.569Z\",\"accountNumber\":\"string\"}"
		
		// when
		let result = try encoder.encode(command.payload)
		let resultString = String(decoding: result, as: UTF8.self)
		
		// then
		XCTAssertEqual(resultString, expected)
	}
	
	func testGetPrintMapForAccountStatement_Response_Decoding() throws {
		
		// given
		let url = bundle.url(forResource: "AccountControllerDetailsGeneric", withExtension: "json")!
		let json = try Data(contentsOf: url)
		
		let productStatementList = StatementObjectData(amount: 999.08,
													   comment: "22.12.2021",
													   lineNumber: 1,
													   operationDate: "22.12.2021",
													   operationType: "DEBIT",
													   tranDate: "22.12.2021",
													   tranTime: "14:52")
		
		let accountDetails = AccountStatementPrintMapResponseData(balanceIn: 10000,
																  balanceOut: 10000,
																  endDate: "22.12.2021",
																  payerAccountNumber: "40817810052005000621",
																  payerCurrency: "RUB",
																  payerFullName: "Иванов Иван Иванович",
																  productStatementList: [productStatementList],
																  responseDate: "20.12.2021 13:06:13",
																  startDate: "01.12.2021",
																  totalCredit: 1000,
																  totalDebit: 1000,
																  transferDate: "20.12.2021")

		let expected = ServerCommands.AccountController.GetPrintMapForAccountStatement.Response(statusCode: .ok,
																								errorMessage: "string",
																								data: accountDetails)
		// when
		let result = try decoder.decode(ServerCommands.AccountController.GetPrintMapForAccountStatement.Response.self, from: json)

		// then
		XCTAssertEqual(result, expected)
	}
}
