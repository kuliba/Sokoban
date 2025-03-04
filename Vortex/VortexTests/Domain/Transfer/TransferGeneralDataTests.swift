//
//  TransferGeneralDataTests.swift
//  VortexTests
//
//  Created by Max Gribov on 20.12.2021.
//

import XCTest
@testable import Vortex

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
        
        let payer = TransferData.Payer(inn: nil, accountId: nil, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
        let amount: Double? = nil
        let transfer = TransferGeneralData(amount: amount, check: false, comment: nil, currencyAmount: "RUB", payer: payer, payeeExternal: nil, payeeInternal: nil)
        
        let result = try encoder.encode(transfer)
        
        try XCTAssertNoDiff(result.jsonDict(), [
            "amount": NSNull(),
            "check": 0,
            "comment": NSNull(),
            "currencyAmount": "RUB",
            "payeeExternal": NSNull(),
            "payeeInternal": NSNull(),
            "payer": [:]
        ])
    }
    
    func test_amountRoundedFinance() throws {
        
        let sut = makeSUT(amount: 10.04)
        
        let encoded = try encoder.encode(sut)
        
        try XCTAssertNoDiff(encoded.jsonDict(), [
            "amount": 10.04,
            "currencyAmount": "",
            "check": false,
            "payeeInternal": NSNull(),
            "comment": NSNull(),
            "payer": [:],
            "payeeExternal": NSNull()
        ])
    }
}

private extension TransferGeneralDataTests {
    
    func makeSUT(amount: Double?) -> TransferGeneralData {
        
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
