//
//  ProductStatementDataTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 20.01.2022.
//

import XCTest
@testable import ForaBank

class ProductStatementDataTests: XCTestCase {

    let bundle = Bundle(for: ProductStatementDataTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    let calendar = Calendar.current

    func testDecoding_Generic() throws {
     
        // given
        let url = bundle.url(forResource: "ProductStatementDataDecodingGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let fastPayment = ProductStatementData.FastPayment(documentComment: "string", foreignBankBIC: "044525491", foreignBankID: "10000001153", foreignBankName: "КУ ООО ПИР Банк - ГК \\\"АСВ\\\"", foreignName: "Петров Петр Петрович", foreignPhoneNumber: "70115110217", opkcid: "A1355084612564010000057CAFC75755",operTypeFP: "string", tradeName: "string", guid: "string")
        
        // when
        let result = try decoder.decode(ProductStatementData.self, from: json)
        
        // then
        XCTAssertEqual(result.mcc, 3245)
        XCTAssertEqual(result.accountId, 10004111477)
        XCTAssertEqual(result.accountNumber, "70601810711002740401")
        XCTAssertEqual(result.amount, 144.21)
        XCTAssertEqual(result.cardTranNumber, "4256901080508437")
        XCTAssertEqual(result.city, "string")
        XCTAssertEqual(result.comment, "Перевод денежных средств. НДС не облагается.")
        XCTAssertEqual(result.country, "string")
        XCTAssertEqual(result.currencyCodeNumeric, 810)

        //"2022-01-20T13:44:17.810Z"
        let date = try Date.date(from: "2022-03-28T21:00:00.000Z", formatter: .iso8601)
        XCTAssertEqual(result.date, date)

        XCTAssertEqual(result.deviceCode, "string")
        XCTAssertEqual(result.documentAmount, 144.21)
        XCTAssertEqual(result.documentId, 10230444722)
        XCTAssertEqual(result.fastPayment, fastPayment)
        XCTAssertEqual(result.groupName, "Прочие операции")
        XCTAssertEqual(result.isCancellation, false)
        XCTAssertEqual(result.md5hash, "75f3ee3b2d44e5808f41777c613f23c9")
        XCTAssertEqual(result.merchantName, "DBO MERCHANT FORA, Zubovskiy 2")
        XCTAssertEqual(result.merchantNameRus, "DBO MERCHANT FORA, Zubovskiy 2")
        XCTAssertEqual(result.opCode, 1)
        XCTAssertEqual(result.operationId, "909743")
        XCTAssertEqual(result.operationType, OperationType.debit)
        XCTAssertEqual(result.paymentDetailType, ProductStatementData.Kind.betweenTheir)
        XCTAssertEqual(result.svgImage, SVGImageData.init(description: "string"))
        XCTAssertEqual(result.terminalCode, "41010601")
        
        let tranDate = try Date.date(from: "2022-03-28T21:00:00.000Z", formatter: .iso8601)
        XCTAssertEqual(result.tranDate, tranDate)
        
        XCTAssertEqual(result.type, OperationEnvironment.inside)
    }
}

