//
//  PaymentTemplateTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 21.12.2021.
//

import XCTest
@testable import ForaBank

class PaymentTemplateTests: XCTestCase {

    let bundle = Bundle(for: PaymentTemplateTests.self)
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    func testDecoding_Generic() throws {
     
        // given
        let url = bundle.url(forResource: "PaymentTemplateDecodingGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        // when
        let result = try decoder.decode(PaymentTemplate.self, from: json)
        
        // then
        XCTAssertEqual(result.groupName, "Переводы СБП")
        XCTAssertEqual(result.name, "Иванов Иван Иванович")
        XCTAssertEqual(result.parameterList.count, 1)
        XCTAssertNotNil(result.parameterList.first! as? Transfer)
        XCTAssertEqual(result.paymentTemplateId, 1)
        XCTAssertEqual(result.sort, 1)
        XCTAssertEqual(result.svgImage.description, "string")
        XCTAssertEqual(result.type, .sfp)
    }
    
    func testEncoding_Min() throws {
        
        // given
        let paymentTemplate = PaymentTemplate(groupName: "Переводы СБП", name: "Иванов Иван Иванович", parameterList: [], paymentTemplateId: 1, sort: 1, svgImage: SVGImageData(description: "string"), type: .sfp)
        
        // when
        let result = try encoder.encode(paymentTemplate)
        
        // then
        //FIXME: extra new line character in jsonString for some reson
        /*
        let url = bundle.url(forResource: "PaymentTemplateEncodingMin", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let resultString = String(decoding: result, as: UTF8.self)
        let jsonString = String(decoding: json, as: UTF8.self)
                                .replacingOccurrences(of: "\n", with: "")
                                .replacingOccurrences(of: " ", with: "")
         */
        let resultString = String(decoding: result, as: UTF8.self)
        let jsonString = "{\"sort\":1,\"svgImage\":\"string\",\"parameterList\":[],\"groupName\":\"Переводы СБП\",\"type\":\"SFP\",\"name\":\"Иванов Иван Иванович\",\"paymentTemplateId\":1}"
        
        XCTAssertEqual(resultString, jsonString)
    }
}
