//
//  TransferGeneralDataTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 20.12.2021.
//

import XCTest
@testable import ForaBank

class TransferGeneralDataTests: XCTestCase {

    let bundle = Bundle(for: TransferGeneralDataTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate

    func testDecoding_Generic() throws {
     
        // given
        let url = bundle.url(forResource: "TransferDecodingGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        // when
        let result = try decoder.decode(TransferGeneralData.self, from: json)
        
        // then
        XCTAssertEqual(result.amount, 100)
        XCTAssertEqual(result.check, false)
        XCTAssertEqual(result.comment, "string")
        XCTAssertEqual(result.currencyAmount, "RUB")
        
        //TODO: check all parameters
    }
    
    func testDecodingServer_Generic() throws {
        
        // given
        let url = bundle.url(forResource: "TransferAnywayDataServerGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        // when
        let result = try decoder.decode(TransferAnywayResponseData.self, from: json)
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testEncoding_Min() throws {
        
        // given
        let payer = TransferData.Payer(inn: nil, accountId: nil, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
        let amount: Double? = nil
        let transfer = TransferGeneralData(amount: amount, check: false, comment: nil, currencyAmount: "RUB", payer: payer, payeeExternal: nil, payeeInternal: nil)
        
        // when
        let result = try encoder.encode(transfer)
        
        // then
        let url = bundle.url(forResource: "TransferEncodingMin", withExtension: "json")!
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
        let expectedResult = "{\"amount\":10.04,\"currencyAmount\":\"\",\"check\":false,\"payeeInternal\":null,\"comment\":null,\"payer\":{},\"payeeExternal\":null}"
        
        // when
        let sutEncoded = try encoder.encode(sut)
        let result = String(data: sutEncoded, encoding: .utf8)
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
}

private extension TransferGeneralDataTests {
    
    func makeSut(amount: Double?) -> TransferGeneralData {
        
        .init(
            amount: amount,
            check: false,
            comment: nil,
            currencyAmount: "", payer: .init(
                inn: nil,
                accountId: nil,
                accountNumber: nil,
                cardId: nil,
                cardNumber: nil,
                phoneNumber: nil),
            payeeExternal: nil,
            payeeInternal: nil)
    }
}
