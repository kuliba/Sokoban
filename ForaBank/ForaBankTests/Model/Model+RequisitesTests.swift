//
//  Model+RequisitesTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 19.09.2023.
//

import XCTest
@testable import ForaBank

final class Model_RequisitesTests: XCTestCase {
    
    func testValidateKppRulesWhenInnCountGreaterThan10() {
        
        let rules = makeSUT().validateKppParameter(12)
        
        XCTAssertEqual(rules.rules.count, 2)
        
        let lengthRule = rules.rules[0] as! Payments.Validation.LengthLimitsRule
        XCTAssertEqual(lengthRule.lengthLimits, [9])
        
        let regexpRule = rules.rules[1] as! Payments.Validation.RegExpRule
        XCTAssertEqual(regexpRule.regExp, "^[0-9]\\d*$")
    }
    
    func testValidateKppRulesWhenInnCountLessThanOrEqualTo10() {
        
        let rules = makeSUT().validateKppParameter(10)
        
        XCTAssertTrue(rules.rules.isEmpty)
    }
    
    func testValidateCompanyNameRules() {
        let rules = makeSUT().validateCompanyNameParameter()
        
        XCTAssertEqual(rules.rules.count, 2)
        
        let minLengthRule = rules.rules[0] as! Payments.Validation.MinLengthRule
        XCTAssertEqual(minLengthRule.minLength, 1)
        
        let maxLengthRule = rules.rules[1] as! Payments.Validation.MaxLengthRule
        XCTAssertEqual(maxLengthRule.maxLength, 160)
    }
    
    // MARK: - Test KPP Parameters
    
    func testCreateKppParameterSingleCompany() {
        
        let model = makeSUT()
        
        let companies = [(kpp: "123456789", name: "Company 1")]
        let kppValidator = validateCompanyNameParameter(model)
        
        let kppParameter = model.createKppParameterInput(
            id: "id",
            value: companies[0].kpp,
            validator: kppValidator)
        
        XCTAssertEqual(kppParameter.value, "123456789")
    }
    
    func testCreateKppParameterMultipleCompanies() {
        
        let model = makeSUT()
        let companies = [
            (kpp: "123456789", name: "Company 1"),
            (kpp: "987654321", name: "Company 2"),
        ]
        let options = model.createParameterOptions(companies)
        let kppValidator = validateCompanyNameParameter(model)
        let icon = ImageData(named: "ic24FileHash") ?? .parameterDocument
        let kppParameter = model.createKppParameterInput(
            id: "kppId",
            value: options.first?.id,
            icon: ImageData(named: "ic24FileHash") ?? .parameterDocument,
            validator: kppValidator
        )
        
        XCTAssertEqual(kppParameter.value, "123456789")
        XCTAssertEqual(kppParameter.icon, icon)
    }
    
    func testCreateKppParameterNoCompanies() {
        
        let model = makeSUT()
        let kppValidator = validateCompanyNameParameter(model)
        let kppParameter = model.createKppParameterInput(
            id: "kppId",
            validator: kppValidator
        )
        
        XCTAssertNil(kppParameter.value)
    }
    
    // MARK: GetCompanyNameParameter Tests
    
    func test_getCompanyNameParameter_withRequisitesService_shouldReturnSuggestCompaniesNameValue() throws {
        
        let sut = makeSUT()
        
        let companyParameter = try sut.getCompanyNameParameter(
            .init(service: .requisites),
            .directCard,
            .anyValue,
            [(kpp: "kpp", name: "suggestCompanyName")]
        )
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(companyParameter.parameter.value, "suggestCompanyName")
    }
    
    func test_getCompanyNameParameter_withTemplateOperation_shouldReturnTemplateNameValue() throws {
        
        let sut = makeSUT()
        
        let companyParameter = try sut.getCompanyNameParameter(
            .init(service: .abroad, source: .template(1)),
            .directCard,
            .anyValue,
            []
        )
        
        XCTAssertNoDiff(companyParameter.parameter.value, "name")
    }
    
    func validateCompanyNameParameter(_ model: Model) -> Payments.Validation.RulesSystem {
        return model.validateCompanyNameParameter()
    }
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line) -> Model {
            
            let sut = Model.mockWithEmptyExcept()
            
            sut.paymentTemplates.value.append(.templateStub(
                paymentTemplateId: 1,
                type: .betweenTheir)
            )
            
            trackForMemoryLeaks(sut, file: file, line: line)
            
            return sut
        }
    
    private func makeSUTWithToken(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        spy: HTTPClientSpy,
        sessionAgent: ActiveInactiveSessionAgent,
        model: Model,
        sut: HTTPClient
    ) {
        let spy = HTTPClientSpy()
        let sessionAgent = ActiveInactiveSessionAgent()
        let model: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent
        )
        let sut = model.authenticatedHTTPClient(
            httpClient: spy
        )
        
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sessionAgent, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return (spy, sessionAgent, model, sut)
    }
}
