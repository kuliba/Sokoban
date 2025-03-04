//
//  TransferMe2MeDataTests.swift
//  VortexTests
//
//  Created by Max Gribov on 21.12.2021.
//

import XCTest
@testable import Vortex

class TransferMe2MeDataTests: XCTestCase {
    
    let bundle = Bundle(for: TransferMe2MeDataTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    
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
        
        let payer = TransferData.Payer(inn: nil, accountId: nil, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil)
        let amount: Double? = nil
        let transfer = TransferMe2MeData(amount: amount, check: false, comment: nil, currencyAmount: "RUB", payer: payer, bankId: "12345678")
        
        let result = try encoder.encode(transfer)
        
        let url = bundle.url(forResource: "TransferMe2MeEncodingMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        let jsonDict: NSDictionary = [
            "amount": NSNull(),
            "bankId": "12345678",
            "check": 0,
            "comment": NSNull(),
            "currencyAmount": "RUB",
            "payer": [:]
        ]
        
        try XCTAssertNoDiff(result.jsonDict(), jsonDict)
        try XCTAssertNoDiff(json.jsonDict(), jsonDict)
    }
    
    func test_amountRoundedFinance() throws {
        
        let sut = makeSUT(amount: 10.04)
        
        let encoded = try encoder.encode(sut)
        
        try XCTAssertNoDiff(encoded.jsonDict(), [
            "amount": 10.04,
            "bankId": "",
            "check": 0,
            "comment": NSNull(),
            "currencyAmount": "",
            "payer": [:]
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(amount: Double?) -> TransferMe2MeData {
        
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
            bankId: "")
    }
}
