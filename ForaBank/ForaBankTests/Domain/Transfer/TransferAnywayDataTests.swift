//
//  TransferAnywayTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 21.12.2021.
//

import XCTest
@testable import ForaBank

class TransferAnywayDataTests: XCTestCase {
    
    let bundle = Bundle(for: TransferAnywayDataTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    func testDecoding_Generic() throws {
     
        // given
        let url = bundle.url(forResource: "TransferAnywayDecodingGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        // when
        let result = try decoder.decode(TransferAnywayData.self, from: json)
        
        // then
        XCTAssertEqual(result.amount, 100)
        XCTAssertEqual(result.check, false)
        XCTAssertEqual(result.comment, "string")
        XCTAssertEqual(result.currencyAmount, "RUB")
        XCTAssertEqual(result.additional.first?.fieldid, 0)
        
        //TODO: check all parameters
    }
    
    func testEncoding_Min() throws {
        
        // given
        let payer = TransferData.Payer(inn: nil, accountId: nil, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
        let amount: Double? = nil
        let transfer = TransferAnywayData(amount: amount, check: false, comment: nil, currencyAmount: "RUB", payer: payer, additional: [.init(fieldid: 0, fieldname: "string", fieldvalue: "string")], puref: nil)
        
        // when
        let result = try encoder.encode(transfer)
        
        // then
        let url = bundle.url(forResource: "TransferAnywayEncodingMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let resultString = String(decoding: result, as: UTF8.self)
        let jsonString = String(decoding: json, as: UTF8.self)
                                .replacingOccurrences(of: "\n", with: "")
                                .replacingOccurrences(of: " ", with: "")
        
        XCTAssertEqual(resultString, jsonString)
    }
    
    func test_amountRoundedFinance() throws {
        
        // given
        let sut = makeSut(amount: 10.04)
        let expectedResult = "{\"amount\":10.04,\"currencyAmount\":\"\",\"check\":false,\"puref\":null,\"additional\":[],\"comment\":null,\"payer\":{}}"
        
        // when
        let sutEncoded = try encoder.encode(sut)
        let result = String(data: sutEncoded, encoding: .utf8)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
}

private extension TransferAnywayDataTests {
    
    func makeSut(amount: Double?) -> TransferAnywayData {
        
        .init(
            amount: amount,
            check: false,
            comment: nil,
            currencyAmount: "",
            payer: .init(
                inn: nil,
                accountId: nil,
                accountNumber: nil,
                cardId: nil,
                cardNumber: nil,
                phoneNumber: nil),
            additional: [],
            puref: nil)
    }
}
