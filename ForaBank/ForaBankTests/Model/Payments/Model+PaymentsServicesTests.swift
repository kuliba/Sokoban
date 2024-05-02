//
//  Model+PaymentsServicesTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 07.06.2023.
//

@testable import ForaBank
import XCTest

final class Model_PaymentsServicesTests: XCTestCase {
    
    func test_paymentsOperator_forOperatorCode_shouldThrowOnEmptyOperatorsList() throws {
        
        let sut = makeSUT()
        
        do {
            _ = try sut.paymentsOperator(forOperatorCode: "transport")
        } catch Payments.Error.missingOperator(forCode: "transport") {}
        
        XCTAssertNoDiff(sut.dictionaryAnywayOperatorGroups(), [])
    }
    
    func test_paymentsOperator_forOperatorCode_shouldThrowOnNonMatchingCode() throws {
        
        let sut = makeSUT([.superDummy()])
        
        do {
            _ = try sut.paymentsOperator(forOperatorCode: "transport")
        } catch Payments.Error.missingOperator(forCode: "transport") {}
        
        XCTAssertEqual(sut.dictionaryAnywayOperatorGroups()?.map(\.code), ["dummy"])
    }
    
    func test_paymentsOperator_forOperatorCode_shouldThrowOnNonMatchingOperator() throws {
        
        let sut = makeSUT([.superDummy()])
        
        do {
            _ = try sut.paymentsOperator(forOperatorCode: "transport")
        } catch Payments.Error.missingOperator(forCode: "transport") {}
        
        XCTAssertEqual(sut.dictionaryAnywayOperatorGroups()?.map(\.code), ["dummy"])
    }
    
    func test_paymentsOperator_forOperatorCode_shouldReturnServiceOnMatchingCode_internetTV() throws {
        
        let sut = makeSUT([.iFora1051001])
        
        let operatorr = try sut.paymentsOperator(forOperatorCode: "iFora||4285")
        
        XCTAssertNoDiff(operatorr, .internetTV)
        XCTAssertNoDiff(sut.dictionaryAnywayOperatorGroups()?.map(\.code), ["iFora||1051001"])
    }
    
    func test_paymentsOperator_forOperatorCode_shouldReturnServiceOnMatchingCode_transport() throws {
        
        let sut = makeSUT([.iFora1051062])
        
        let operatorr = try sut.paymentsOperator(forOperatorCode: "iFora||PYD")
        
        XCTAssertNoDiff(operatorr, .transport)
        XCTAssertNoDiff(sut.dictionaryAnywayOperatorGroups()?.map(\.code), ["iFora||1051062"])
    }
    
    func test_paymentsOperator_forOperatorCode_shouldReturnServiceOnMatchingCode_utility() throws {
        
        let sut = makeSUT([.iFora1031001])
        
        let operatorr = try sut.paymentsOperator(forOperatorCode: "iFora||C31")
        
        XCTAssertNoDiff(operatorr, .utility)
        XCTAssertNoDiff(sut.dictionaryAnywayOperatorGroups()?.map(\.code), ["iFora||1031001"])
    }

    // MARK: - paymentsParameterRepresentablePaymentsServices
    
//    func test_paymentsParameterRepresentablePaymentsServices_TypeEmpty_DefaultParameterInfo() async throws {
//        
//        let parameterData = ParameterData.test(content: "value", id: "IdInputTest", isRequired: true, regExp: "", title: "title", type: "", svgImage: .test)
//        let model = makeSUT()
//        let parameterRepresentable = try await model.paymentsParameterRepresentablePaymentsServices(parameterData: parameterData)
//       
//        guard let selectParameter = parameterRepresentable as? Payments.ParameterInfo else {
//            XCTFail("Expected ParameterInfo")
//            return
//        }
//        
//        XCTAssertEqual(selectParameter.id, "IdInputTest")
//        XCTAssertEqual(selectParameter.value, "value")
//        XCTAssertEqual(selectParameter.title, "title")
//        XCTAssertEqual(selectParameter.icon, .image(parameterData.iconData ?? .parameterDocument))
//        XCTAssertEqual(selectParameter.group, .init(id: "info", type: .info))
//    }
    
//    func test_paymentsParameterRepresentablePaymentsServices_InputIsRequiredWhenRegExpNil() async throws {
//        
//        let parameterData = ParameterData.test(content: "content", id: "inputTest", isRequired: true, regExp: nil, title: "title", type: "input", svgImage: .test)
//        let model = makeSUT([.iFora1031001])
//        
//        let parameterRepresentable = try await model.paymentsParameterRepresentablePaymentsServices(parameterData: parameterData)
//        
//        guard let selectParameter = parameterRepresentable as? Payments.ParameterInput else {
//            XCTFail("Expected ParameterInput")
//            return
//        }
//        
//        let regExpStr = parameterData.regExp ?? "^.{1,}$"
//        let regExpRules: any PaymentsValidationRulesSystemRule = Payments.Validation.RegExpRule(regExp: regExpStr, actions: [.post: .warning((parameterData.subTitle ?? ""))])
//        let expectedValidator = Payments.Validation.RulesSystem(rules: [regExpRules])
//        
//        XCTAssertEqual(selectParameter.id, "inputTest")
//        XCTAssertEqual(selectParameter.value, "content")
//        XCTAssertEqual(selectParameter.icon, ImageData(with: parameterData.svgImage ?? .test))
//        XCTAssertEqual(selectParameter.title, "title")
//        XCTAssertEqual(selectParameter.validator, expectedValidator)
//    }
    
//    func test_paymentsParameterRepresentablePaymentsServices_InputisRequiredWhenRegExpEmpty() async throws {
//        
//        let parameterData = ParameterData.test(content: "value", id: "IdInputTest", isRequired: true, regExp: "", title: "title", type: "input", svgImage: .test)
//        let model = makeSUT()
//        let parameterRepresentable = try await model.paymentsParameterRepresentablePaymentsServices(parameterData: parameterData)
//
//        guard let selectParameter = parameterRepresentable as? Payments.ParameterInput else {
//            XCTFail("Expected ParameterInput")
//            return
//        }
//        let regExpStr = parameterData.regExp ?? "^.{1,}$"
//        let regExpRules: any PaymentsValidationRulesSystemRule = Payments.Validation.RegExpRule(regExp: regExpStr, actions: [.post: .warning((parameterData.subTitle ?? ""))])
//        let expectedValidator = Payments.Validation.RulesSystem(rules: [regExpRules])
//        
//        XCTAssertEqual(selectParameter.id, "IdInputTest")
//        XCTAssertEqual(selectParameter.value, "value")
//        XCTAssertEqual(selectParameter.icon, ImageData(with: parameterData.svgImage ?? .test))
//        XCTAssertEqual(selectParameter.title, "title")
//        XCTAssertEqual(selectParameter.validator, .init(rules: [regExpRules]))
//    }
    
//    func test_paymentsParameterRepresentablePaymentsServices_InputisRequiredWithRegExp() async throws {
//        
//        let parameterData = ParameterData.test(content: "value", id: "IdInputTest", isRequired: true, regExp: #"\d{5}810\d{12}|\d{5}643\d{12}$"#, title: "title", type: "input", svgImage: .test)
//        let model = makeSUT()
//        let parameterRepresentable = try await model.paymentsParameterRepresentablePaymentsServices(parameterData: parameterData)
//
//        guard let selectParameter = parameterRepresentable as? Payments.ParameterInput else {
//            XCTFail("Expected ParameterInput")
//            return
//        }
//        let regExpStr = parameterData.regExp ?? "^.{1,}$"
//        let regExpRules: any PaymentsValidationRulesSystemRule = Payments.Validation.RegExpRule(regExp: regExpStr, actions: [.post: .warning((parameterData.subTitle ?? ""))])
//        let expectedValidator = Payments.Validation.RulesSystem(rules: [regExpRules])
//        
//        XCTAssertEqual(selectParameter.id, "IdInputTest")
//        XCTAssertEqual(selectParameter.value, "value")
//        XCTAssertEqual(selectParameter.icon, ImageData(with: parameterData.svgImage ?? .test))
//        XCTAssertEqual(selectParameter.title, "title")
//        XCTAssertEqual(selectParameter.validator, .init(rules: [regExpRules]))
//    }
    
//    func test_paymentsParameterRepresentablePaymentsServices_InputisNotRequiredWithRegExpNil() async throws {
//        
//        let parameterData = ParameterData.test(content: "value", id: "IdInputTest", isRequired: false, regExp: nil, title: "title", type: "input", svgImage: .test)
//        let model = makeSUT()
//        let parameterRepresentable = try await model.paymentsParameterRepresentablePaymentsServices(parameterData: parameterData)
//
//        guard let selectParameter = parameterRepresentable as? Payments.ParameterInput else {
//            XCTFail("Expected ParameterInput")
//            return
//        }
//        
//        XCTAssertEqual(selectParameter.id, "IdInputTest")
//        XCTAssertEqual(selectParameter.value, "value")
//        XCTAssertEqual(selectParameter.icon, ImageData(with: parameterData.svgImage ?? .test))
//        XCTAssertEqual(selectParameter.title, "title")
//        XCTAssertEqual(selectParameter.validator, .init(rules: []))
//    }
    
//    func test_paymentsParameterRepresentablePaymentsServices_InputisNotRequiredWithRegExpEmpty() async throws {
//        
//        let parameterData = ParameterData.test(content: "value", id: "IdInputTest", isRequired: false, regExp: nil, title: "title", type: "input", svgImage: .test)
//        let model = makeSUT()
//        let parameterRepresentable = try await model.paymentsParameterRepresentablePaymentsServices(parameterData: parameterData)
//
//        guard let selectParameter = parameterRepresentable as? Payments.ParameterInput else {
//            XCTFail("Expected ParameterInput")
//            return
//        }
//        
//        XCTAssertEqual(selectParameter.id, "IdInputTest")
//        XCTAssertEqual(selectParameter.value, "value")
//        XCTAssertEqual(selectParameter.icon, ImageData(with: parameterData.svgImage ?? .test))
//        XCTAssertEqual(selectParameter.title, "title")
//        XCTAssertEqual(selectParameter.validator, .init(rules: []))
//    }
    
//    func test_paymentsParameterRepresentablePaymentsServices_InputisNotRequiredWithRegExp() async throws {
//        
//        let parameterData = ParameterData.test(content: "value", id: "IdInputTest", isRequired: false, regExp: #"\d{5}810\d{12}|\d{5}643\d{12}$"#, title: "title", type: "input", svgImage: .test)
//        let model = makeSUT()
//        let parameterRepresentable = try await model.paymentsParameterRepresentablePaymentsServices(parameterData: parameterData)
//
//        guard let selectParameter = parameterRepresentable as? Payments.ParameterInput else {
//            XCTFail("Expected ParameterInput")
//            return
//        }
//        let regExpStr = parameterData.regExp ?? "^.{1,}$"
//        let regExpRules: any PaymentsValidationRulesSystemRule = Payments.Validation.OptionalRegExpRule(regExp: regExpStr, actions: [.post: .warning((parameterData.subTitle ?? ""))])
//        let expectedValidator = Payments.Validation.RulesSystem(rules: [regExpRules])
//        
//        XCTAssertEqual(selectParameter.id, "IdInputTest")
//        XCTAssertEqual(selectParameter.value, "value")
//        XCTAssertEqual(selectParameter.icon, ImageData(with: parameterData.svgImage ?? .test))
//        XCTAssertEqual(selectParameter.title, "title")
//        XCTAssertEqual(selectParameter.validator, .init(rules: [regExpRules]))
//    }
    
    // MARK: - Helper Tests
    
    func test_superDummyOperatorData() throws {
        
        let localAgent = OperatorsLocalAgentSub([.superDummy(code: "transport")])
        let model: Model = .mockWithEmptyExcept(
            localAgent: localAgent
        )
        
        let data = try XCTUnwrap(model.dictionaryAnywayOperator(for: "transport"))
        
        XCTAssertEqual(data.code, "transport")
        XCTAssertEqual(data.name, "transport")
        XCTAssertEqual(data.parentCode, "transport")
    }
    
    // MARK: - Test Helpers
    
    private func makeSUT(
        _ operatorGroupData: [OperatorGroupData] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let localAgent = OperatorsLocalAgentSub(operatorGroupData)
        let sut: Model = .mockWithEmptyExcept(
            localAgent: localAgent
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

// MARK: - Helpers

final class OperatorsLocalAgentSub: LocalAgentProtocol {
    
    private let operatorGroupData: [OperatorGroupData]
    
    init(_ operatorGroupData: [OperatorGroupData]) {
        
        self.operatorGroupData = operatorGroupData
    }
    
    func store<T>(_ data: T, serial: String?) throws where T : Encodable {
        
        let _ : T = unimplemented()
    }
    
    func load<T>(type: T.Type) -> T? where T : Decodable {
        
        switch type {
        case is [OperatorGroupData].Type:
            return operatorGroupData as? T
            
        case is [OperatorGroupData.OperatorData].Type:
            return operatorGroupData.map(\.operators) as? T
            
        default:
            return unimplemented()
        }
    }
    
    func clear<T>(type: T.Type) throws {
        
    }
    
    func serial<T>(for type: T.Type) -> String? {
        
        unimplemented()
    }
}

extension OperatorGroupData {
    
    static let iFora1051001: Self = .dummy(
        code: "iFora||1051001",
        name: "Телефония, интернет, коммерческое ТВ",
        operators: [.iFora4285]
    )
    
    static let iFora1051062: Self = .dummy(
        code: "iFora||1051062",
        name: "Транспорт",
        operators: [.iForaPYD]
    )
    
    static let iFora1031001: Self = .dummy(
        code: "iFora||1031001",
        name: "",
        operators: [.iForaC31]
    )
    
    static func superDummy(code: String = "dummy") -> Self {
        
        .dummy(code: code, name: code, operators: [.dummy(code: code, name: code, parentCode: code)])
    }
    
    static func dummy(
        city: String? = nil,
        code: String,
        isGroup: Bool = false,
        logotypeList: [OperatorGroupData.LogotypeData] = [],
        name: String,
        operators: [OperatorGroupData.OperatorData],
        region: String? = nil,
        synonymList: [String] = []
    ) -> Self {
        
        self.init(
            city: city,
            code: code,
            isGroup: isGroup,
            logotypeList: logotypeList,
            name: name,
            operators: operators,
            region: region,
            synonymList: synonymList
        )
    }
}

extension OperatorGroupData.OperatorData {
    
    static let iForaPYD: Self = .dummy(
        code: "iFora||PYD",
        name: "Подорожник",
        parentCode: "iFora||1051062"
    )
    
    static let iForaC31: Self = .dummy(
        code: "iFora||C31",
        name: "Газпром Межрегионгаз Ярославль",
        parentCode: "iFora||1031001"
    )
    
    static func dummy(
        city: String? = nil,
        code: String,
        isGroup: Bool = false,
        logotypeList: [OperatorGroupData.LogotypeData] = [],
        name: String,
        parameterList: [ParameterData] = [],
        parentCode: String,
        region: String? = nil,
        synonymList: [String] = []
    ) -> Self {
        
        self.init(
            city: city,
            code: code,
            isGroup: isGroup,
            logotypeList: logotypeList,
            name: name,
            parameterList: parameterList,
            parentCode: parentCode,
            region: region,
            synonymList: synonymList
        )
    }
}


private struct EquatableRule: Equatable {
    
    let rule: any PaymentsValidationRulesSystemRule
    
    static func == (lhs: EquatableRule, rhs: EquatableRule) -> Bool {
        
        let lhsDescription = String(describing: lhs.rule)
        let rhsDescription = String(describing: rhs.rule)
        
        return lhsDescription == rhsDescription
    }
}

extension Payments.Validation.RulesSystem: Equatable {
    
    public static func == (lhs: Payments.Validation.RulesSystem, rhs: Payments.Validation.RulesSystem) -> Bool {
        
        let lhsRules = lhs.rules.map { EquatableRule(rule: $0) }
        let rhsRules = rhs.rules.map { EquatableRule(rule: $0) }
        
        return lhsRules == rhsRules
    }
}

extension Payments.ParameterSelect.Option: Equatable {
    
    public static func == (lhs: Payments.ParameterSelect.Option, rhs: Payments.ParameterSelect.Option) -> Bool {
        
        let lhsRules = lhs.id.map { $0 }
        let rhsRules = rhs.id.map { $0 }
        
        return lhsRules == rhsRules
    }
}

