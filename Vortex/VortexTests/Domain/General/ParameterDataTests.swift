//
//  ParameterDataTests.swift
//  VortexTests
//
//  Created by Max Gribov on 28.02.2023.
//

import XCTest
@testable import Vortex

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
        XCTAssertEqual(result?[1].id, "USD")
        XCTAssertEqual(result?[1].name, "USD")
    }
    
    func testOptions_Extended() throws {

        // given
        let parameterData = ParameterData(dataType: "=:1=оплата за газ:2=оплата за тех обслуживание")
        
        // when
        let result = parameterData.options(style: .extended)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
        XCTAssertEqual(result?[0].id, "1")
        XCTAssertEqual(result?[0].name, "оплата за газ")
        XCTAssertEqual(result?[1].id, "2")
        XCTAssertEqual(result?[1].name, "оплата за тех обслуживание")
    }

    func testOptions_DataTypeNil_isNil() throws {

        // given
        let parameterData = ParameterData(minLength: nil, maxLength: nil, regExp: nil)
        
        // when
        let resultGeneralStyle = parameterData.options(style: .general)
        let resultCurrencyStyle = parameterData.options(style: .currency)
        let resultExtendedStyle = parameterData.options(style: .extended)

        // then
        XCTAssertNil(resultGeneralStyle)
        XCTAssertNil(resultCurrencyStyle)
        XCTAssertNil(resultExtendedStyle)
    }
 
    func testOptions_UnknowStyle_isNil_() throws {

        // given
        let parameterData = ParameterData(dataType: "=*1=оплата за газ*2=оплата за тех обслуживание")
        
        // when
        let resultGeneralStyle = parameterData.options(style: .general)
        let resultCurrencyStyle = parameterData.options(style: .currency)
        let resultExtendedStyle = parameterData.options(style: .extended)

        // then
        XCTAssertNil(resultGeneralStyle)
        XCTAssertNil(resultCurrencyStyle)
        XCTAssertNil(resultExtendedStyle)
    }
    
    //MARK: - Test Validator

    func testValidator_MinLength() throws {

        // given
        let parameterData = ParameterData(minLength: 4, maxLength: nil, regExp: nil)

        // when
        let result = parameterData.validator
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.rules.count, 1)
        XCTAssertEqual(result.rules.minLength.count, 1)
        XCTAssertEqual(result.rules.maxLength.count, 0)
        XCTAssertEqual(result.rules.regExp.count, 0)
        XCTAssertEqual(result.rules.optionalRegExp.count, 0)
    }

    func testValidator_MaxLength() throws {

        // given
        let parameterData = ParameterData(minLength: nil, maxLength: 4, regExp: nil)

        // when
        let result = parameterData.validator
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.rules.count, 1)
        XCTAssertEqual(result.rules.minLength.count, 0)
        XCTAssertEqual(result.rules.maxLength.count, 1)
        XCTAssertEqual(result.rules.regExp.count, 0)
        XCTAssertEqual(result.rules.optionalRegExp.count, 0)
    }

    func testValidator_RegExp() throws {

        // given
        let parameterData = ParameterData(minLength: nil, maxLength: nil, regExp: "^[0-9]\\d*$")

        // when
        let result = parameterData.validator
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.rules.count, 1)
        XCTAssertEqual(result.rules.minLength.count, 0)
        XCTAssertEqual(result.rules.maxLength.count, 0)
        XCTAssertEqual(result.rules.regExp.count, 1)
        XCTAssertEqual(result.rules.optionalRegExp.count, 0)
    }

    func testValidator_AllValue() throws {

        // given
        let parameterData = ParameterData(minLength: 4, maxLength: 5, regExp: "^[0-9]\\d*$")

        // when
        let result = parameterData.validator
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result.rules.count, 3)
        XCTAssertEqual(result.rules.minLength.count, 1)
        XCTAssertEqual(result.rules.maxLength.count, 1)
        XCTAssertEqual(result.rules.regExp.count, 1)
        XCTAssertEqual(result.rules.optionalRegExp.count, 0)
    }
}

private extension ParameterData {
    
    init(dataType: String) {
        
        self.init(content: nil, dataType: dataType, id: UUID().uuidString, isPrint: nil, isRequired: nil, mask: nil, maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: nil, regExp: nil, subTitle: nil, title: "", type: "", inputFieldType: .unknown, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .constant)
    }
    
    init(minLength: Int?, maxLength: Int?, regExp: String?) {
        
        self.init(content: nil, dataType: nil, id: UUID().uuidString, isPrint: nil, isRequired: nil, mask: nil, maxLength: maxLength, minLength: minLength, order: nil, rawLength: 0, readOnly: nil, regExp: regExp, subTitle: nil, title: "", type: "", inputFieldType: .unknown, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .constant)
    }

}

// MARK: DSL

private extension Array where Element == any PaymentsValidationRulesSystemRule {
    
    var minLength: Self {
        
        filter{ $0 is Payments.Validation.MinLengthRule }
    }
    
    var maxLength: Self {
        
        filter{ $0 is Payments.Validation.MaxLengthRule }
    }
    
    var regExp: Self {
        
        filter{ $0 is Payments.Validation.RegExpRule }
    }
    
    var optionalRegExp: Self {
        
        filter{ $0 is Payments.Validation.OptionalRegExpRule }
    }
}
