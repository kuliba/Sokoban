//
//  RelaxRegExpRuleTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.06.2023.
//

@testable import Vortex
import XCTest

final class RelaxRegExpRuleTests: XCTestCase {
    
    private typealias ValidationActions = [Payments.Validation.Stage : Payments.Validation.Action]
    
    func test_relaxRegExpRule_shouldReturnEmptyOnEmpty() {
        
        let regExp = ""
        let actions: ValidationActions = [:]
        let rule: Payments.Validation.RegExpRule = .init(
            regExp: regExp,
            actions: actions
        )
        
        let relaxed: PaymentsValidationRulesSystemRule = rule.relaxed
        
        XCTAssertNotNil(relaxed as? Payments.Validation.OptionalRegExpRule)
        XCTAssertNoDiff(rule.relaxed.regExp, regExp)
        XCTAssertNoDiff(rule.relaxed.actions, actions)
    }
    
    func test_relaxRegExpRule_shouldReturnEmptyOnEmptyAction() {
        
        let regExp = "some regular expression"
        let actions: ValidationActions = [:]
        let rule: Payments.Validation.RegExpRule = .init(
            regExp: regExp,
            actions: actions
        )
        
        let relaxed: PaymentsValidationRulesSystemRule = rule.relaxed
        
        XCTAssertNotNil(relaxed as? Payments.Validation.OptionalRegExpRule)
        XCTAssertNoDiff(rule.relaxed.regExp, regExp)
        XCTAssertNoDiff(rule.relaxed.actions, actions)
    }
    
    func test_relaxRegExpRule_shouldReturnOptionalRegExpRule() {
        
        let regExp = "some regular expression"
        let actions: ValidationActions = [.post: .warning("Warning")]
        let rule: Payments.Validation.RegExpRule = .init(
            regExp: regExp,
            actions: actions
        )
        
        let relaxed: PaymentsValidationRulesSystemRule = rule.relaxed
        
        XCTAssertNotNil(relaxed as? Payments.Validation.OptionalRegExpRule)
        XCTAssertNoDiff(rule.relaxed.regExp, regExp)
        XCTAssertNoDiff(rule.relaxed.actions, actions)
    }
}
