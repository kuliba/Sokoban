//
//  ConsentMe2MePullResponseDataTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 20.01.2022.
//

import XCTest
@testable import ForaBank

class ConsentMe2MePullResponseDataTests: XCTestCase {

    let bundle = Bundle(for: ConsentMe2MePullResponseDataTests.self)
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    func testDecoding_Generic() throws {
     
        // given
        let url = bundle.url(forResource: "ConsentMe2MePullResponseDataDecodingGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let consentList = ConsentMe2MePullData(active: true, bankId: "1crt88888881", beginDate: "01.01.2022 00:00:00", consentId: 1, endDate: "01.01.2022 00:00:00", oneTimeConsent: true)
        
        // when
        let result = try decoder.decode(ConsentMe2MePullResponseData.self, from: json)
        
        // then
        XCTAssertEqual(result.consentList, [consentList])
        
    }
    
    func testEncoding_Min() throws {
        
        // given
        let consentMe2MePullData = ConsentMe2MePullData(active: nil, bankId: "string", beginDate: "string", consentId: 1, endDate: "string", oneTimeConsent: nil)
        
        // when
        let result = try encoder.encode(consentMe2MePullData)
        
        // then
        let resultString = String(decoding: result, as: UTF8.self)
        let jsonString = "{\"consentId\":1,\"bankId\":\"string\",\"endDate\":\"string\",\"beginDate\":\"string\"}"
        
        XCTAssertEqual(resultString, jsonString)
    }
    
    func testEncoding_Max() throws {
        
        // given
        let consentMe2MePullData = ConsentMe2MePullData(active: true, bankId: "string", beginDate: "string", consentId: 1, endDate: "string", oneTimeConsent: true)
        
        // when
        let result = try encoder.encode(consentMe2MePullData)
        
        // then
        let resultString = String(decoding: result, as: UTF8.self)
        let jsonString = "{\"consentId\":1,\"active\":true,\"bankId\":\"string\",\"endDate\":\"string\",\"oneTimeConsent\":true,\"beginDate\":\"string\"}"
        
        XCTAssertEqual(resultString, jsonString)
    }
}
