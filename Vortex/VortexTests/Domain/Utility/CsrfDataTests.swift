//
//  CsrfDtoTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 19.01.2022.
//

import XCTest
@testable import ForaBank

class CsrfDataTests: XCTestCase {

    let bundle = Bundle(for: CsrfDataTests.self)
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    func testDecoding_Generic() throws {
     
        // given
        let url = bundle.url(forResource: "CsrfDtoDecodingGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        // when
        let result = try decoder.decode(CsrfData.self, from: json)
        
        // then
        XCTAssertEqual(result.cert, "string")
        XCTAssertEqual(result.headerName, "string")
        XCTAssertEqual(result.pk, "string")
        XCTAssertEqual(result.sign, "string")
        XCTAssertEqual(result.token, "string")
    }
    
    func testEncoding_Min() throws {
        
        // given
        let csrfDto = CsrfData(cert: "string", headerName: "string", pk: "string", sign: "string", token: "string")
        
        // when
        let result = try encoder.encode(csrfDto)
        
        // then
        let resultString = String(decoding: result, as: UTF8.self)
        let jsonString = "{\"headerName\":\"string\",\"pk\":\"string\",\"cert\":\"string\",\"sign\":\"string\",\"token\":\"string\"}"
        
        XCTAssertEqual(resultString, jsonString)
    }
}
