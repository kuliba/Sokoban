//
//  TransferMe2MeTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 21.12.2021.
//

import XCTest
@testable import ForaBank

class TransferMe2MeTests: XCTestCase {

    let bundle = Bundle(for: TransferMe2MeTests.self)
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    func testDecoding_Generic() throws {
     
        // given
        let url = bundle.url(forResource: "TransferMe2MeDecodingGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        // when
        let result = try decoder.decode(TransferMe2MeData.self, from: json)
        
        // then
        XCTAssertEqual(result.amount, 100)
        XCTAssertEqual(result.check, false)
        XCTAssertEqual(result.comment, "string")
        XCTAssertEqual(result.currencyAmount, "RUB")
        
        //TODO: check all parameters
    }
    
    func testEncoding_Min() throws {
        
        // given
        let payer = TransferAbstractData.Payer(inn: nil, accountId: nil, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
        let transfer = TransferMe2MeData(amount: nil, check: false, comment: nil, currencyAmount: "RUB", payer: payer, bankId: "12345678")
        
        // when
        let result = try encoder.encode(transfer)
        
        // then
        let url = bundle.url(forResource: "TransferMe2MeEncodingMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let resultString = String(decoding: result, as: UTF8.self)
        let jsonString = String(decoding: json, as: UTF8.self)
                                .replacingOccurrences(of: "\n", with: "")
                                .replacingOccurrences(of: " ", with: "")
        
        XCTAssertEqual(resultString, jsonString)
    }
}
