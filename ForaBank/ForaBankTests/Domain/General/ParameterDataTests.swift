//
//  ParameterDataTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 28.02.2023.
//

import XCTest
@testable import ForaBank

class ParameterDataTests: XCTestCase {

    func testOptions_General() throws {

        // given
        let parameterData = ParameterData(dataType: "=,inn_oktmo=ИНН и ОКТМО подразделения,number=Номер подразделения")
        
        // when
        let result = parameterData.options(style: .general)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
        XCTAssertEqual(result?[0].id, "inn_oktmo")
        XCTAssertEqual(result?[0].name, "ИНН и ОКТМО подразделения")
        XCTAssertEqual(result?[1].id, "number")
        XCTAssertEqual(result?[1].name, "Номер подразделения")
    }
    
    func testOptions_Currency() throws {

        // given
        let parameterData = ParameterData(dataType: "=;RUB=USD,EUR; USD=RUB,EUR")
        
        // when
        let result = parameterData.options(style: .currency)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
        XCTAssertEqual(result?[0].id, "RUB")
        XCTAssertEqual(result?[0].name, "RUB")
        XCTAssertEqual(result?[1].id, "EUR")
        XCTAssertEqual(result?[1].name, "EUR")
        
    }
}

private extension ParameterData {
    
    init(dataType: String) {
        
        self.init(content: nil, dataType: dataType, id: UUID().uuidString, isPrint: nil, isRequired: nil, mask: nil, maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: nil, regExp: nil, subTitle: nil, title: "", type: "", inputFieldType: nil, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .constant)
    }
}
