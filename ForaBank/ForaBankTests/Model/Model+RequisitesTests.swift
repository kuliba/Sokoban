//
//  Model+RequisitesTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 19.09.2023.
//

import XCTest
@testable import ForaBank

final class Model_RequisitesTests: XCTestCase {
    
    func testValidateKppRulesWhenInnCountLessThanOrEqualTo10() throws {
        
        let rules = makeSUT().validateKppParameter(10)
        
        XCTAssertEqual(rules.rules.count, 2)
        
        let lengthRule = try XCTUnwrap(rules.rules[0] as? Payments.Validation.OptionalRegExpRule)
        XCTAssertEqual(lengthRule.regExp, "^\\d{9}$")
        
        let regexpRule = try XCTUnwrap(rules.rules[1] as? Payments.Validation.OptionalRegExpRule)
        XCTAssertEqual(regexpRule.regExp, "^[0-9]\\d*$")
    }

    func testValidateKppRulesWhenInnCountGreaterThan10() {
        
        let rules = makeSUT().validateKppParameter(12)
        
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
    
    func testCreateParameterOptionsWithNilKppWhenInnCountLessThanOrEqualTo10() {
        
        let model = makeSUT()
        let companies = [
            (kpp: nil, name: "Company 1"),
            (kpp: "123456789", name: "Company 2")
        ]
        
        let options = model.createParameterOptions(companies, 10)
        
        XCTAssertEqual(options.count, 1)
        XCTAssertEqual(options[0].id, "123456789")
        XCTAssertEqual(options[0].name, "123456789")
        XCTAssertEqual(options[0].subname, "Company 2")
    }

    func testCreateParameterOptionsWhenInnCountGreaterThan10() {
        
        let model = makeSUT()
        let companies = [
            (kpp: "123456789", name: "Company 1"),
            (kpp: "987654321", name: "Company 2")
        ]
        
        let options = model.createParameterOptions(companies, 12)
        
        XCTAssertEqual(options.count, 2)
        XCTAssertTrue(options[0].id.hasPrefix("Company 1"))
        XCTAssertEqual(options[0].name, "Company 1")
        XCTAssertNil(options[0].subname)
        XCTAssertTrue(options[1].id.hasPrefix("Company 2"))
        XCTAssertEqual(options[1].name, "Company 2")
        XCTAssertNil(options[1].subname)
    }
    
    // MARK: - Test Operation Step
    
    func testCreateOperationStepWhenInnValueCountLessThanOrEqualTo10() {
        
        let model = makeSUT()
        let step = model.createOperationStep(
            parameters: PPMock.testParams,
            isCompleted: false,
            innValueCount: 10,
            kppParameterId: "kppParam"
        )
        
        XCTAssertEqual(step.parameters.count, 3)
        XCTAssertEqual(step.front.visible.count, 3)
        XCTAssertEqual(step.front.visible, ["param1", "kppParam", "param3"])
        XCTAssertFalse(step.front.isCompleted)
        XCTAssertEqual(step.back.required, ["param1", "param3"])
        XCTAssertNil(step.back.processed)
        XCTAssertEqual(step.back.stage, .remote(.start))
    }

    func testCreateOperationStepWhenInnValueCountGreaterThan10() {
        
        let model = makeSUT()
        let step = model.createOperationStep(
            parameters: PPMock.testParams,
            isCompleted: true,
            innValueCount: 12,
            kppParameterId: "kppParam"
        )
        
        XCTAssertEqual(step.parameters.count, 3)
        XCTAssertEqual(step.front.visible.count, 2)
        XCTAssertEqual(step.front.visible, ["param1", "param3"])
        XCTAssertTrue(step.front.isCompleted)
        XCTAssertEqual(step.back.required, ["param1", "param3"])
        XCTAssertNil(step.back.processed)
        XCTAssertEqual(step.back.stage, .remote(.start))
    }
    
    // MARK: - Test KPP Validator
    
    func testShouldShowKppParameterForRequisitesService() {
        
        let model = makeSUT()
        XCTAssertTrue(model.shouldShowKppParameter(.requisites, 10))
        XCTAssertFalse(model.shouldShowKppParameter(.requisites, 12))
    }

    func testShouldShowKppParameterForNonRequisitesServices() {
        
        let model = makeSUT()
        XCTAssertTrue(model.shouldShowKppParameter(.abroad, 5))
        XCTAssertTrue(model.shouldShowKppParameter(.abroad, 15))
        XCTAssertTrue(model.shouldShowKppParameter(.sfp, 10))
        XCTAssertTrue(model.shouldShowKppParameter(.sfp, 20))
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
        let options = model.createParameterOptions(companies, 10)
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
    
    typealias PPMock = Payments.ParameterMock
    
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

//private extension PaymentsParameterRepresentable {
private extension Payments.ParameterMock {
    
    static let testParams: [PaymentsParameterRepresentable] = [
        Payments.ParameterMock(id: "param1"),
        Payments.ParameterMock(id: "kppParam"),
        Payments.ParameterMock(id: "param3")
    ]
}
