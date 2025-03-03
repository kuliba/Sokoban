//
//  PaymentTemplateTests.swift
//  VortexTests
//
//  Created by Max Gribov on 21.12.2021.
//

import XCTest
@testable import Vortex

class PaymentTemplateTests: XCTestCase {
    
    let bundle = Bundle(for: PaymentTemplateTests.self)
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    func testDecoding_Generic() throws {
        
        // given
        let url = bundle.url(forResource: "PaymentTemplateDecodingGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        
        // when
        let result = try decoder.decode(PaymentTemplateData.self, from: json)
        
        // then
        XCTAssertEqual(result.groupName, "Переводы СБП")
        XCTAssertEqual(result.name, "Иванов Иван Иванович")
        XCTAssertEqual(result.parameterList.count, 1)
        XCTAssertNotNil(result.parameterList.first! as? TransferGeneralData)
        XCTAssertEqual(result.paymentTemplateId, 1)
        XCTAssertEqual(result.sort, 1)
        XCTAssertEqual(result.svgImage?.description, "string")
        XCTAssertEqual(result.type, .sfp)
    }
    
    func testEncoding_Min() throws {
        
        let paymentTemplate = PaymentTemplateData(
            groupName: "Переводы СБП",
            name: "Иванов Иван Иванович",
            parameterList: [],
            paymentTemplateId: 1,
            productTemplate: nil,
            sort: 1,
            svgImage: SVGImageData(description: "string"),
            type: .sfp
        )
        
        let result = try encoder.encode(paymentTemplate)
        
        XCTAssertNoDiff(try result.jsonDict(), [
            "sort":1,
            "svgImage":"string",
            "parameterList":[],
            "groupName":"Переводы СБП",
            "type":"SFP",
            "name":"Иванов Иван Иванович",
            "paymentTemplateId":1])
    }
}
