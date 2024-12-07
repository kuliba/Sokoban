//
//  ServerCommandsAccountControllerTests.swift
//  VortexTests
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

	//MARK: - GetAccountStatement

	func testGetAccountStatement_Response_Decoding() throws {

		// given
		let url = bundle.url(forResource: "GetAccountStatementResponseGeneric", withExtension: "json")!
		let json = try Data(contentsOf: url)
        let date = try Date.date(from: "2022-03-28T21:00:00.000Z", formatter: .iso8601)

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
                                                                           opkcid: "A1355084612564010000057CAFC75755", operTypeFP: "string", tradeName: "string", guid: "string"),
														groupName: "Прочие операции",
														isCancellation: false,
														md5hash: "75f3ee3b2d44e5808f41777c613f23c9",
														merchantName: "DBO MERCHANT VORTEX, Zubovskiy 2",
														merchantNameRus: "DBO MERCHANT VORTEX, Zubovskiy 2",
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
	
	func testGetAccountStatement_Response_Min_Decoding() throws {

		// given
		let url = bundle.url(forResource: "GetAccountStatementResponseGenericMin", withExtension: "json")!
		let json = try Data(contentsOf: url)
        let date = try Date.date(from: "2022-03-28T21:00:00.000Z", formatter: .iso8601)

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
														fastPayment: nil,
														groupName: "Прочие операции",
														isCancellation: nil,
														md5hash: "75f3ee3b2d44e5808f41777c613f23c9",
														merchantName: nil,
														merchantNameRus: nil,
														opCode: nil,
														operationId: "123",
														operationType: .debit,
														paymentDetailType: .betweenTheir,
														svgImage: nil,
														terminalCode: nil,
														tranDate: nil,
														type: .inside)

		let expected = ServerCommands.AccountController.GetAccountStatement.Response(statusCode: .ok,
																					 errorMessage: "string",
																					 data: [accountStatementData])

		// when
		let result = try decoder.decode(ServerCommands.AccountController.GetAccountStatement.Response.self, from: json)

		// then
		XCTAssertEqual(result, expected)
	}
	
    
    func testGetAccountStatement_Response_From_Server_Decoding() throws {

        // given
        guard let url = bundle.url(forResource: "GetAccountStatementResponseServer", withExtension: "json") else {
            XCTFail()
            return
        }
        
        let json = try Data(contentsOf: url)

        XCTAssertNoThrow(try decoder.decode(ServerCommands.AccountController.GetAccountStatement.Response.self, from: json))
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
