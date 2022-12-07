//
//  QRMappingTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 07.12.2022.
//

import XCTest
@testable import ForaBank

class QRMappingTests: XCTestCase {

    func testDecoding() throws {
        
        // given
        let bundle = Bundle(for: QRMappingTests.self)
        let decoder = JSONDecoder()
        guard let url = bundle.url(forResource: "QRMappingJSON", withExtension: "json") else {
            XCTFail()
            return
        }
        let json = try Data(contentsOf: url)

        // when
        let result = try decoder.decode(QRMapping.self, from: json)
        
        // then
        XCTAssertEqual(result.parameters.count, 11)
        XCTAssertEqual(result.parameters[0].parameter, .general(.inn))
        XCTAssertEqual(result.parameters[0].keys, ["payeeinn"])
        XCTAssertEqual(result.parameters[0].type, .string)
        //TODO: GENERAL_AMOUNT
        //TODO: GENERAL_TECHCODE
        
        //TODO: operators count
        //TODO: iFora||4747
    }
}
