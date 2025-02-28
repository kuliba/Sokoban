//
//  CsrfDtoTests.swift
//  VortexTests
//
//  Created by Дмитрий on 19.01.2022.
//

import XCTest
@testable import Vortex

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
        
        let (cert, headerName, pk, sign, token) = (anyMessage(), anyMessage(), anyMessage(), anyMessage(), anyMessage())
        let csrfDto = CsrfData(cert: cert, headerName: headerName, pk: pk, sign: sign, token: token)
        
        let result = try encoder.encode(csrfDto)
        
        try XCTAssertNoDiff(result.jsonDict(), [
            "headerName": headerName,
            "pk": pk,
            "cert": cert,
            "sign": sign,
            "token": token
        ])
    }
}
