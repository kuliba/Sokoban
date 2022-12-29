//
//  PaymentsValidationRulesSystemTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 08.12.2022.
//

import XCTest
@testable import ForaBank

class PaymentsValidationRulesSystemTests: XCTestCase {}

//MARK: - Min Length Rule

extension PaymentsValidationRulesSystemTests {
    
    func testMinLengthRule_Valid() throws {

        // given
        let rule = Payments.Validation.MinLengthRule(minLenght: 3, actions: [:])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.evaluate("1234")
        
        // then
        XCTAssertTrue(result)
    }
    
    func testMinLengthRule_InValid() throws {

        // given
        let rule = Payments.Validation.MinLengthRule(minLenght: 3, actions: [:])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.evaluate("12")
        
        // then
        XCTAssertFalse(result)
    }
    
    func testMinLengthRule_InValid_Action() throws {

        // given
        let rule = Payments.Validation.MinLengthRule(minLenght: 3, actions: [.post: .warning("min lenght 3")])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.action(with: "12", for: .post)
        
        // then
        XCTAssertEqual(result, .warning("min lenght 3"))
    }
}


//MARK: - Max Length Rule

extension PaymentsValidationRulesSystemTests {
    
    func testMaxLengthRule_Valid() throws {

        // given
        let rule = Payments.Validation.MaxLengthRule(maxLenght: 5, actions: [:])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.evaluate("1234")
        
        // then
        XCTAssertTrue(result)
    }
    
    func testMaxLengthRule_InValid() throws {

        // given
        let rule = Payments.Validation.MaxLengthRule(maxLenght: 5, actions: [:])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.evaluate("123456")
        
        // then
        XCTAssertFalse(result)
    }
    
    func testMaxLengthRule_InValid_Action() throws {

        // given
        let rule = Payments.Validation.MaxLengthRule(maxLenght: 3, actions: [.post: .warning("max lenght 3")])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.action(with: "12345", for: .post)
        
        // then
        XCTAssertEqual(result, .warning("max lenght 3"))
    }
}

//MARK: - Length Limits Rule

extension PaymentsValidationRulesSystemTests {
    
    func testLengthLimitsRule_Valid() throws {

        // given
        let rule = Payments.Validation.LengthLimitsRule(lengthLimits: [3, 5], actions: [:])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.evaluate("123")
        
        // then
        XCTAssertTrue(result)
    }
    
    func testLengthLimitsRule_InValid() throws {

        // given
        let rule = Payments.Validation.LengthLimitsRule(lengthLimits: [3, 5], actions: [:])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.evaluate("1234")
        
        // then
        XCTAssertFalse(result)
    }
    
    func testLengthLimitsRule_InValid_Action() throws {

        // given
        let rule = Payments.Validation.LengthLimitsRule(lengthLimits: [3, 5], actions: [.post: .warning("value lenght 3 or 5")])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.action(with: "1234", for: .post)
        
        // then
        XCTAssertEqual(result, .warning("value lenght 3 or 5"))
    }
}

//MARK: - Contains String Rule

extension PaymentsValidationRulesSystemTests {
    
    func testContainsStringRule_Valid() throws {

        // given
        let rule = Payments.Validation.ContainsStringRule(start: 1, expected: "23", actions: [:])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.evaluate("123")
        
        // then
        XCTAssertTrue(result)
    }
    
    func testContainsStringRule_InValid() throws {

        // given
        let rule = Payments.Validation.ContainsStringRule(start: 0, expected: "810", actions: [:])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.evaluate("1234")
        
        // then
        XCTAssertFalse(result)
    }
    
    func testContainsStringRule_InValid_Action() throws {

        // given
        let rule = Payments.Validation.ContainsStringRule(start: 3, expected: "810", actions: [.post: .warning("Value must contain 810")])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.action(with: "1234", for: .post)
        
        // then
        XCTAssertEqual(result, .warning("Value must contain 810"))
    }
}

//MARK: - Regular Expression Rule Tests

extension PaymentsValidationRulesSystemTests {

    func testRegularExpression_Valid() throws {

        // given
        let rule = Payments.Validation.RegExpRule(regExp: "^[0-9]\\d*$", actions: [:])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.evaluate("123456789")
        
        // then
        XCTAssertTrue(result)
    }
    
    func testRegularExpression_InValid() throws {
        
        // given
        let rule = Payments.Validation.RegExpRule(regExp: "[0-9]", actions: [:])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.evaluate("string")
        
        // then
        XCTAssertFalse(result)
    }
    
    func testRegularExpression_InValid_Action() throws {
        
        // given
        let rule = Payments.Validation.RegExpRule(regExp: "[0-9]", actions: [.post: .warning("Warning: only digits")])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [rule])
        
        // when
        let result = ruleSystem.action(with: "string", for: .post)
        
        // then
        XCTAssertEqual(result, .warning("Warning: only digits"))
    }
}

//MARK: - Action

extension PaymentsValidationRulesSystemTests {
    
    func testAction() throws {

        // given
        let minLenghtRule = Payments.Validation.MinLengthRule(minLenght: 3, actions: [.post: .warning("min lenght 3")])
        let maxLengthRule = Payments.Validation.MaxLengthRule(maxLenght: 10, actions: [.post: .warning("max lenght 3")])
        let containsStringRule = Payments.Validation.ContainsStringRule(start: 3, expected: "810", actions: [.post: .warning("Value must contain 810")])
        let lenghtLimitsRule = Payments.Validation.LengthLimitsRule(lengthLimits: [3, 5, 10], actions: [.post: .warning("value lenght 3, 5 or 10")])
        let ruleSystem = Payments.Validation.RulesSystem(rules: [minLenghtRule, maxLengthRule, containsStringRule, lenghtLimitsRule])
        
        // when
        let result = ruleSystem.action(with: "1234", for: .post)
        
        // then
        XCTAssertEqual(result, .warning("Value must contain 810"))
    }
}

//MARK: - Any Value

extension PaymentsValidationRulesSystemTests {
    
    func testAnyValue() throws {

        // given
        let ruleSystem = Payments.Validation.RulesSystem.anyValue
        
        // when
        let result = ruleSystem.evaluate(nil)
        
        // then
        XCTAssertTrue(result)
    }
}
