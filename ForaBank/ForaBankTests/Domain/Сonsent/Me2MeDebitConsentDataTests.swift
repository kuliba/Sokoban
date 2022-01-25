//
//  Me2MeDebitConsentDataTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 20.01.2022.
//

import XCTest
@testable import ForaBank

class Me2MeDebitConsentDataTests: XCTestCase {

    let bundle = Bundle(for: Me2MeDebitConsentDataTests.self)
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    func testDecoding_Generic() throws {
     
        // given
        let url = bundle.url(forResource: "Me2MeDebitConsentDataDecodingGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        // when
        let result = try decoder.decode(Me2MeDebitConsentData.self, from: json)
        
        // then
        XCTAssertEqual(result.accountId, 10000184511)
        XCTAssertEqual(result.amount, 100)
        XCTAssertEqual(result.bankRecipientID, "string")
        XCTAssertEqual(result.cardId, 10000184511)
        XCTAssertEqual(result.fee, 10)
        XCTAssertEqual(result.rcvrMsgId, "string")
        XCTAssertEqual(result.recipientID, "string")
        XCTAssertEqual(result.refTrnId, "string")
    }
    
    func testEncoding_Min() throws {
        
        // given
        let me2MeDebitConsentData = Me2MeDebitConsentData(accountId: 10000184511, amount: 100, bankRecipientID: nil, cardId: 10000184511, fee: 10, rcvrMsgId: nil, recipientID: nil, refTrnId: nil)
        
        // when
        let result = try encoder.encode(me2MeDebitConsentData)
        
        // then
        let resultString = String(decoding: result, as: UTF8.self)
        let jsonString = "{\"amount\":100,\"cardId\":10000184511,\"accountId\":10000184511,\"fee\":10}"
        
        XCTAssertEqual(resultString, jsonString)
    }
    
    func testEncoding_Max() throws {
        
        // given
        let me2MeDebitConsentData = Me2MeDebitConsentData(accountId: 10000184511, amount: 100, bankRecipientID: "string", cardId: 10000184511, fee: 10, rcvrMsgId: "string", recipientID: "string", refTrnId: "string")
        // when
        let result = try encoder.encode(me2MeDebitConsentData)
        
        // then
        let resultString = String(decoding: result, as: UTF8.self)
        let jsonString = "{\"amount\":100,\"accountId\":10000184511,\"cardId\":10000184511,\"recipientID\":\"string\",\"bankRecipientID\":\"string\",\"rcvrMsgId\":\"string\",\"fee\":10,\"refTrnId\":\"string\"}"

        XCTAssertEqual(resultString, jsonString)
    }
}
