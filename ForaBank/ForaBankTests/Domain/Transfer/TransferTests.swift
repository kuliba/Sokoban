//
//  TransferTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 20.12.2021.
//

import XCTest
@testable import ForaBank

class TransferTests: XCTestCase {

    let bundle = Bundle(for: TransferTests.self)
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    func testDecoding_Generic() throws {
     
        // given
        let url = bundle.url(forResource: "TransferDecodingGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        // when
        let result = try decoder.decode(TransferData.self, from: json)
        
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
        let transfer = TransferData(amount: nil, check: false, comment: nil, currencyAmount: "RUB", payer: payer, payeeExternal: nil, payeeInternal: nil)
        
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
}
