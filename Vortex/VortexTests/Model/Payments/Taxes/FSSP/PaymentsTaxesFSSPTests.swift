//
//  PaymentsTaxesFSSPTests.swift
//  VortexTests
//
//  Created by Max Gribov on 05.06.2023.
//

import XCTest
@testable import Vortex

final class PaymentsTaxesFSSPTests: XCTestCase {
    
    func test_paymentsStepFSSP_correctStep() throws {
        
        let sut = makeSUT()
        let operation = Payments.Operation(service: .fssp)
        let searchTypeParamID = "a3_SearchType_1_1"
        
        let result = try sut.paymentsStepFSSP(operation, for: 0)
        
        XCTAssertEqual(result.parameters.map(\.id), [
            Payments.Parameter.Identifier.operator.rawValue,
            Payments.Parameter.Identifier.header.rawValue,
            Payments.Parameter.Identifier.product.rawValue,
            searchTypeParamID])
        
        XCTAssertEqual(result.front.visible, [Payments.Parameter.Identifier.header.rawValue, searchTypeParamID])
        XCTAssertTrue(result.front.isCompleted)
        XCTAssertEqual(result.back.stage, .remote(.start))
        XCTAssertEqual(result.back.required, [searchTypeParamID])
        XCTAssertNil(result.back.processed)
    }
    
    func test_paymentsStepFSSP_errorForUnexpectedStepIndex() async throws {
        
        let sut = makeSUT()
        let operation = Payments.Operation(service: .fssp)
        
        XCTAssertThrowsError(_ = try sut.paymentsStepFSSP(operation, for: 1))
    }
    
    func test_paymentsStepFSSP_errorForEmptyProducts() async throws {
        
        let sut = makeSUT([])
        let operation = Payments.Operation(service: .fssp)
        
        XCTAssertTrue(sut.products.value.isEmpty)
        XCTAssertThrowsError(_ = try sut.paymentsStepFSSP(operation, for: 0))
    }
}

//TODO: paymentsParameterRepresentableTaxesFSSP tests

//MARK: - paymentsParameterRepresentableTaxesFSSP

extension PaymentsTaxesFSSPTests {
    
    func test_paymentsProcessOperationResetVisibleTaxesFSSP_amountParameterRemovedFromVisibleForRemoteConfirmStep() async throws {
        
        // given
        let sut = makeSUT()
        let (operation, amountParamID) = try makeOperationWithVisibleAmountParameter(and: "parameter_id_must_retain", stage: .remote(.confirm))
        XCTAssertTrue(operation.visibleParameters.map(\.id).contains(amountParamID))
        
        // when
        let result = try await sut.paymentsProcessOperationResetVisibleTaxesFSSP(operation)
        
        // then
        XCTAssertEqual(result, ["parameter_id_must_retain"])
    }
    
    func test_paymentsProcessOperationResetVisibleTaxesFSSP_nilForNonConfirmLastStepBackStage() async throws {
        
        // given
        let sut = makeSUT()
        let (operation, _) = try makeOperationWithVisibleAmountParameter(and: "parameter_id", stage: .remote(.start))
        
        // when
        let result = try await sut.paymentsProcessOperationResetVisibleTaxesFSSP(operation)
        
        // then
        XCTAssertNil(result)
    }
}

//MARK: - paymentsProcessDependencyReducerFSSP

extension PaymentsTaxesFSSPTests {
    
    func test_paymentsProcessDependencyReducerFSSP_nilForAnyParamIDAndEmptyParametersList() {
        
        let sut = makeSUT()
        
        XCTAssertNil(sut.paymentsProcessDependencyReducerFSSP(parameterId: "anyParamID", parameters: []))
    }
    
    func test_paymentsProcessDependencyReducerFSSP_nilForParameterIdNotInParametersList() {
        
        let sut = makeSUT()
        
        XCTAssertNil(sut.paymentsProcessDependencyReducerFSSP(parameterId: "notDocumentParamID", parameters: [makeDocumentParameter()]))
    }
    
    func test_paymentsProcessDependencyReducerFSSP_correctUpdatedValidationRulesForInputParameterSearchType20DocumentType20() throws {
        
        let sut = makeSUT()
        let searchTypeParameter = makeSearchTypeParameter(value: "20")
        let documentTypeParameter = makeDocumentTypeParameter(value: "20")
        let documentParameter = makeDocumentParameter()
        
        try expect(sut,
                   newRules: [makeLenghtLimitsRule10()],
                   forInputParameterWithId: documentParameter.id,
                   withParameters: [searchTypeParameter, documentTypeParameter, documentParameter])
    }
    
    func test_paymentsProcessDependencyReducerFSSP_correctUpdatedValidationRulesForInputParameterSearchType20DocumentType50() throws {
        
        let sut = makeSUT()
        let searchTypeParameter = makeSearchTypeParameter(value: "20")
        let documentTypeParameter = makeDocumentTypeParameter(value: "50")
        let documentParameter = makeDocumentParameter()
        
        try expect(sut,
                   newRules: [makeLenghtLimitsRule10()],
                   forInputParameterWithId: documentParameter.id,
                   withParameters: [searchTypeParameter, documentTypeParameter, documentParameter])
    }
    
    func test_paymentsProcessDependencyReducerFSSP_correctUpdatedValidationRulesForInputParameterSearchType20DocumentType60() throws {
        
        let sut = makeSUT()
        let searchTypeParameter = makeSearchTypeParameter(value: "20")
        let documentTypeParameter = makeDocumentTypeParameter(value: "60")
        let documentParameter = makeDocumentParameter()
        
        try expect(sut,
                   newRules: [makeLenghtLimitsRule10()],
                   forInputParameterWithId: documentParameter.id,
                   withParameters: [searchTypeParameter, documentTypeParameter, documentParameter])
    }
    
    func test_paymentsProcessDependencyReducerFSSP_correctUpdatedValidationRulesForInputParameterSearchType20DocumentType30() throws {
        
        let sut = makeSUT()
        let searchTypeParameter = makeSearchTypeParameter(value: "20")
        let documentTypeParameter = makeDocumentTypeParameter(value: "30")
        let documentParameter = makeDocumentParameter()
        
        try expect(sut,
                   newRules: [makeLenghtLimitsRule10_12()],
                   forInputParameterWithId: documentParameter.id,
                   withParameters: [searchTypeParameter, documentTypeParameter, documentParameter])
    }
    
    func test_paymentsProcessDependencyReducerFSSP_correctUpdatedValidationRulesForInputParameterSearchType20DocumentType40() throws {
        
        let sut = makeSUT()
        let searchTypeParameter = makeSearchTypeParameter(value: "20")
        let documentTypeParameter = makeDocumentTypeParameter(value: "40")
        let documentParameter = makeDocumentParameter()
        
        try expect(sut,
                   newRules: [makeLenghtLimitsRule11()],
                   forInputParameterWithId: documentParameter.id,
                   withParameters: [searchTypeParameter, documentTypeParameter, documentParameter])
    }
    
    func test_paymentsProcessDependencyReducerFSSP_correctUpdatedValidationRulesForInputParameterSearchTypeUIN() throws {
        
        let sut = makeSUT()
        let searchTypeParameter = makeSearchTypeParameter(value: "30")
        let documentParameter = makeDocumentParameter()
        
        try expect(sut,
                   newRules: [makeLenghtLimitsRule20_25(), makeRegExpRuleUIN()],
                   forInputParameterWithId: documentParameter.id,
                   withParameters: [searchTypeParameter, documentParameter],
                   isInputTypeNumber: true)
    }
    
    func test_paymentsProcessDependencyReducerFSSP_correctUpdatedValidationRulesForInputParameterSearchTypeIP() throws {
        
        let sut = makeSUT()
        let searchTypeParameter = makeSearchTypeParameter(value: "40")
        let documentParameter = makeDocumentParameter()
        
        try expect(sut,
                   newRules: [makeRegExpRuleIP()],
                   forInputParameterWithId: documentParameter.id,
                   withParameters: [searchTypeParameter, documentParameter],
                   isInputTypeNumber: true)
    }
    
    func test_paymentsProcessDependencyReducerFSSP_nilForNilSearchType() throws {
        
        let sut = makeSUT()
        let searchTypeParameter = makeSearchTypeParameter(value: nil)
        let documentParameter = makeDocumentParameter()
        
        let result = sut.paymentsProcessDependencyReducerFSSP(parameterId: documentParameter.id, parameters: [searchTypeParameter, documentParameter])
        
        XCTAssertNil(result)
    }
    
    func test_paymentsProcessDependencyReducerFSSP_nilForUnsupportedSearchType() throws {
        
        let sut = makeSUT()
        let searchTypeParameter = makeSearchTypeParameter(value: "")
        let documentParameter = makeDocumentParameter()
        
        let result = sut.paymentsProcessDependencyReducerFSSP(parameterId: documentParameter.id, parameters: [searchTypeParameter, documentParameter])
        
        XCTAssertNil(result)
    }
    
    func test_paymentsProcessDependencyReducerFSSP_expectingNilForSearchTypeParamWithValueAndDocumentTypeParamWithNil() throws {
        
        let sut = makeSUT()
        let searchTypeParameter = makeSearchTypeParameter(value: "20")
        let documentTypeParameter = makeDocumentTypeParameter(value: nil)
        let documentParameter = makeDocumentParameter()
        
        let result = sut.paymentsProcessDependencyReducerFSSP(parameterId: documentParameter.id, parameters: [searchTypeParameter, documentTypeParameter, documentParameter])
        
        XCTAssertNil(result)
    }
    
    func test_paymentsProcessDependencyReducerFSSP_expectingNilForSearchTypeParamWithValueAndDocumentTypeParamWithUnsupportedValue() throws {
        
        let sut = makeSUT()
        let searchTypeParameter = makeSearchTypeParameter(value: "20")
        let documentTypeParameter = makeDocumentTypeParameter(value: "100500")
        let documentParameter = makeDocumentParameter()
        
        let result = sut.paymentsProcessDependencyReducerFSSP(parameterId: documentParameter.id, parameters: [searchTypeParameter, documentTypeParameter, documentParameter])
        
        XCTAssertNil(result)
    }
}

//MARK: - Helpers

private extension PaymentsTaxesFSSPTests {
    
    private func makeSUT(
        _ counts: ProductTypeCounts = [(.card, 1)],
        currencies: [CurrencyData] = [.rub],
        file: StaticString = #file,
        line: UInt = #line) -> Model {
            
            let sut = Model.mockWithEmptyExcept()
            
            sut.products.value = makeProductsData(counts)
            sut.currencyList.value = currencies
            
            trackForMemoryLeaks(sut, file: file, line: line)
            
            return sut
        }
    
    func makeOperationWithVisibleAmountParameter(and parameterId: Payments.Parameter.ID, stage: Payments.Operation.Stage) throws -> (operation: Payments.Operation, amountParamID: Payments.Parameter.ID)  {
        
        let amountParam = Payments.ParameterAmount(value: nil, title: "", currencySymbol: "RUB", validator: .init(minAmount: 0, maxAmount: nil))
        let anyNotAmountParam = Payments.ParameterMock(id: parameterId)
        let step = Payments.Operation.Step(parameters: [anyNotAmountParam, amountParam], front: .init(visible: [anyNotAmountParam.id, amountParam.id], isCompleted: true), back: .init(stage: stage, required: [], processed: nil))
        let operation = Payments.Operation(service: .fssp)
        let updatedOperation = try operation.appending(step: step)
        
        return (updatedOperation, amountParam.id)
    }
    
    func makeLenghtLimitsRule10_12() -> Payments.Validation.LengthLimitsRule {
        
        .init(lengthLimits: [10, 12], actions: [.post: .warning("Должен состоять из 10 или 12 цифр")])
    }
    
    func makeLenghtLimitsRule10() -> Payments.Validation.LengthLimitsRule {
        
        .init(lengthLimits: [10], actions: [.post: .warning("Должен состоять из 10 цифр")])
    }
    
    func makeLenghtLimitsRule11() -> Payments.Validation.LengthLimitsRule {
        
        .init(lengthLimits: [11], actions: [.post: .warning("Должен состоять из 11 цифр")])
    }
    
    func makeLenghtLimitsRule20_25() -> Payments.Validation.LengthLimitsRule {
        
        .init(lengthLimits: [20, 25], actions: [.post: .warning("Должен состоять из 20 или 25 цифр")])
    }
    
    func makeRegExpRuleUIN() -> Payments.Validation.RegExpRule {
        
        .init(regExp: "^([0-9]{20}|[0-9]{25})$", actions: [.post: .warning("Должен состоять из 20 или 25 цифр")])
    }
    
    func makeRegExpRuleIP() -> Payments.Validation.RegExpRule {
        
        .init(regExp: "^[0-9]{1,7}[/][0-9]{2}[/][0-9]{2}[/][0-9]{2}$|^[0-9]{1,7}[/][0-9]{2}[/][0-9]{5}-ИП$", actions: [.post: .warning("Пример: 1108/10/41/33 или 107460/09/21014-И")])
    }
    
    func expect(_ sut: Model, newRules rules: [any PaymentsValidationRulesSystemRule], forInputParameterWithId parameterId: Payments.Parameter.ID, withParameters parameters: [PaymentsParameterRepresentable], isInputTypeNumber: Bool = false, file: StaticString = #file, line: UInt = #line) throws {
        
        let result = try XCTUnwrap(sut.paymentsProcessDependencyReducerFSSP(parameterId: parameterId, parameters: parameters) as? Payments.ParameterInput, "Expected ParameterInput", file: file, line: line)
        
        XCTAssertEqual(result.validator.rules.count, rules.count, "Result validation rules count: \(result.validator.rules.count) not equal to expected count: \(rules.count)", file: file, line: line)
        
        for pair in zip(result.validator.rules, rules) {
            
            switch (pair.0, pair.1) {
            case let (lhs as Payments.Validation.LengthLimitsRule, rhs as Payments.Validation.LengthLimitsRule):
                XCTAssertEqual(lhs, rhs, "Result LengthLimitsRule not equal expected LengthLimitsRule", file: file, line: line)
                
            case let (lhs as Payments.Validation.RegExpRule, rhs as Payments.Validation.RegExpRule):
                XCTAssertEqual(lhs, rhs, "Result RegExpRule not equal expected RegExpRule", file: file, line: line)
                
            default:
                XCTFail("Unexpected rules types", file: file, line: line)
            }
        }
        
        if isInputTypeNumber {
            
            XCTAssertEqual(result.inputType, .number, "Result inputType not equal expected inputType", file: file, line: line)
        }
    }
}

//MARK: - Parameters Helpers

private extension PaymentsTaxesFSSPTests {
    
    func makeSearchTypeParameter(value: Payments.Parameter.Value = "20") -> Payments.ParameterSelectDropDownList {
        
        .init(
            .init(id: "a3_SearchType_1_1", value: value),
            title: "Выберете тип",
            options: [
                .init(id: "20", name: "Документ", icon: nil),
                .init(id: "30", name: "УИН", icon: nil),
                .init(id: "40", name: "ИП", icon: nil)
            ], placement: .top)
    }
    
    func makeDocumentTypeParameter(value: Payments.Parameter.Value) -> Payments.ParameterMock {
        
        .init(id: "a3_docName_1_2", value: value)
    }
    
    func makeDocumentParameter() -> Payments.ParameterInput {
        
        .init(
            .init(id: "a3_docNumber_2_2", value: nil),
            title: "Документ",
            validator: .anyValue)
    }
}

//MARK: - Extensions

extension Payments.Validation.LengthLimitsRule: Equatable {
    
    public static func == (lhs: Payments.Validation.LengthLimitsRule, rhs: Payments.Validation.LengthLimitsRule) -> Bool {
        
        lhs.actions == rhs.actions && lhs.lengthLimits == rhs.lengthLimits
    }
}

extension Payments.Validation.RegExpRule: Equatable {
    
    public static func == (lhs: Payments.Validation.RegExpRule, rhs: Payments.Validation.RegExpRule) -> Bool {
        
        lhs.actions == rhs.actions && lhs.regExp == rhs.regExp
    }
}

