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
    
    // MARK: - AdditionalList
    
    func test_additionalList_QRPersAccWithViewTypeOutput_returnsNil() {
        
        let res = makeListValue(.qrPersAcc, parameterData: .pdClearOutput)
        
        XCTAssertEqual(res, nil)
    }
    
    func test_additionalList_QRPersAccWithViewTypeIntput_returnsEmpty() {
        
        let res = makeListValue(.qrPersAcc, parameterData: .pdClearInput)
        
        XCTAssertEqual(res, "")
    }
    
    func test_additionalList_QRPersAccWithAccountInputFieldTypeNil_returnsEmpty() {
        
        let res = makeListValue(.qrPersAcc, parameterData: .pdAccountInpFTNil)
        
        XCTAssertEqual(res, "")
    }
    
    func test_additionalList_AccountInputFieldTypeAccount_QRwithoutRawData_returnsEmpty() {
        
        let res = makeListValue(.qrWithoutAccountNumberForPayment, parameterData: .pdAccountInpFTAccount)
        
        XCTAssertEqual(res, "")
    }
    
    func test_additionalList_PersonalAccountWithInputAccount_returnQRPersaccValue() {
        
        let qrCode: QRCode = .qrPersAcc
        let res = makeListValue(qrCode, parameterData: .pdAccountInpFTPersonalAccount)
        
        XCTAssertEqual(res, qrCode.rawData["persacc"])
    }
    
    func test_additionalList_AccountWithInputAccount_returnQRValue() {
        
        let qrCode: QRCode = .qrPersAcc
        let res = makeListValue(qrCode, parameterData: .pdAccountInpFTAccount)
        
        XCTAssertEqual(res, qrCode.rawData["persacc"])
    }
    
    func test_additionalList_AccountWithInputAccount_WithPhoneNumber_returnQRPhoneValue() {
        
        let qrCode: QRCode = .qrPhone
        let res = makeListValue(qrCode, parameterData: .pdAccountInpFTAccount)
        
        XCTAssertEqual(res, qrCode.rawData["phone"])
    }
    
    func test_additionalList_AccountWithInputAccount_WithNumabo_returnQRNumaboValue() {
        
        let qrCode: QRCode = .qrNumAbo
        let res = makeListValue(qrCode, parameterData: .pdAccountInpFTAccount)
        
        XCTAssertEqual(res, qrCode.rawData["numabo"])
    }
    
    func test_additionalList_CodeWithCategory_returтRawData() {
        
        let res = makeListValue(.qrPersAcc, parameterData: .pdCode)
        
        XCTAssertEqual(res, "1")
    }
    
    func test_additionalList_CodeWithoutCategory_retursEmpty() {
        
        let res = makeListValue(.qrPersAccCategoryNil, parameterData: .pdCode)
        
        XCTAssertEqual(res, "")
    }
    
    // MARK: - paymentsParameterRepresentablePaymentsServices
    
    func test_paymentsParameterRepresentablePaymentsServices_TypeEmpty_DefaultParameterInfo() async throws {
        
        let parameterData = makeParameterData(isRequired: true, type: "")
        let selectParameter = try await makeParameterInfo(parameterData: parameterData)
        XCTAssertEqual(selectParameter.id, "IdInputTest")
        XCTAssertEqual(selectParameter.value, "value")
        XCTAssertEqual(selectParameter.title, "title")
        XCTAssertEqual(selectParameter.icon, .image(parameterData.iconData ?? .parameterDocument))
        XCTAssertEqual(selectParameter.group, .init(id: "info", type: .info))
    }
   
    func test_paymentsParameterRepresentablePaymentsServices_InputIsRequiredWhenRegExpNil() async throws {
        
        let selectParameter = try await makeParameterInput(parameterData: makeParameterData(isRequired: true, regExp: nil))
        assertParameterInput(selectParameter, iconData: selectParameter.icon, validator: makeValidator(regExp: nil, isRequired: true))
    }
    
    func test_paymentsParameterRepresentablePaymentsServices_InputisRequiredWhenRegExpEmpty() async throws {
        
        let selectParameter = try await makeParameterInput(parameterData: makeParameterData(isRequired: true, regExp: ""))
        assertParameterInput(selectParameter, iconData: selectParameter.icon, validator: makeValidator(regExp: "", isRequired: true))
    }
    
    func test_paymentsParameterRepresentablePaymentsServices_InputisRequiredWithRegExp() async throws {
        
        let selectParameter = try await makeParameterInput(parameterData: makeParameterData(isRequired: true, regExp: String.regExp))
        assertParameterInput(selectParameter, iconData: selectParameter.icon, validator: makeValidator(regExp: String.regExp, isRequired: true))
    }

    func test_paymentsParameterRepresentablePaymentsServices_InputisNotRequiredWithRegExpNil() async throws {
        
        let selectParameter = try await makeParameterInput(parameterData: makeParameterData(isRequired: false, regExp: nil))
        assertParameterInput(selectParameter, iconData: selectParameter.icon, validator: .init(rules: []))
    }
    
    func test_paymentsParameterRepresentablePaymentsServices_InputisNotRequiredWithRegExpEmpty() async throws {
        
        let selectParameter = try await makeParameterInput(parameterData: makeParameterData(isRequired: false, regExp: ""))
        assertParameterInput(selectParameter, iconData: selectParameter.icon, validator: .init(rules: []))
    }

    func test_paymentsParameterRepresentablePaymentsServices_InputisNotRequiredWithRegExp() async throws {
       
        let selectParameter = try await makeParameterInput(parameterData: makeParameterData(isRequired: false, regExp: String.regExp))
        assertParameterInput(selectParameter, iconData: selectParameter.icon, validator: makeValidator(regExp: String.regExp, isRequired: false))
    }
    
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
    
    private func makeListValue(
        _ qrCode: QRCode,
        parameterData: ParameterData
    ) ->  String? {
        
        let model = makeSUT()
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        
        let list = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = list?.first?.fieldValue
        
        return res
    }

    private func assertParameterInput(
        _ parameterInput: Payments.ParameterInput,
        id: String = "IdInputTest",
        value: String? = "value",
        iconData: ImageData?,
        title: String = "title",
        validator: Payments.Validation.RulesSystem,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(parameterInput.id, id, file: file, line: line)
        XCTAssertEqual(parameterInput.value, value, file: file, line: line)
        XCTAssertEqual(parameterInput.icon, iconData, file: file, line: line)
        XCTAssertEqual(parameterInput.title, title, file: file, line: line)
        XCTAssertEqual(parameterInput.validator, validator, file: file, line: line)
    }
    
    private func makeParameterData(
        content: String = "value",
        id: String = "IdInputTest",
        isRequired: Bool = false,
        regExp: String? = nil,
        title: String = "title",
        type: String = "input",
        svgImage: SVGImageData = .test
    ) -> ParameterData {
        
        return ParameterData.test(
            content: content,
            id: id,
            isRequired: isRequired,
            regExp: regExp,
            title: title,
            type: type,
            svgImage: svgImage
        )
    }

    private func makeParameterInput(
        parameterData: ParameterData,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> Payments.ParameterInput {
        
        let model = makeSUT(file: file, line: line)
        let parameterRepresentable = try await model.paymentsParameterRepresentablePaymentsServices(parameterData: parameterData)

        guard let selectParameter = parameterRepresentable as? Payments.ParameterInput else {
            XCTFail("Expected ParameterInput", file: file, line: line)
            throw XCTestError(.failureWhileWaiting)
        }

        return selectParameter
    }
    
    private func makeParameterInfo(
        parameterData: ParameterData,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws -> Payments.ParameterInfo {
        
        let model = makeSUT(file: file, line: line)
        let parameterRepresentable = try await model.paymentsParameterRepresentablePaymentsServices(parameterData: parameterData)

        guard let selectParameter = parameterRepresentable as? Payments.ParameterInfo else {
            XCTFail("Expected ParameterInfo")
            throw XCTestError(.failureWhileWaiting)
        }

        return selectParameter
    }
    
    private func makeValidator(regExp: String?, isRequired: Bool) -> Payments.Validation.RulesSystem {
        
        let regExpStr = regExp ?? "^.{1,}$"
        let rule: any PaymentsValidationRulesSystemRule
        
        if isRequired {
            rule = Payments.Validation.RegExpRule(regExp: regExpStr, actions: [.post: .warning((""))])
            
        } else {
            rule = Payments.Validation.OptionalRegExpRule(regExp: regExpStr, actions: [.post: .warning((""))])
        }
        
        return Payments.Validation.RulesSystem(rules: [rule])
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


private extension QRCode {
    
    static let qrPersAcc: Self = getQR()
    static let qrPersAccCategoryNil: Self = getQR(category: nil)
    static let qrWithoutAccountNumberForPayment: Self = getQR(withRawData: false)
    static let qrPhone = getQR(qrType: .phone)
    static let qrNumAbo = getQR(qrType: .numabo)
    
    private enum QRType {
        
        case persacc, phone, numabo
    }
    
    private static func getQR(
        withRawData: Bool = true,
        qrType: QRType = .persacc,
        persacc: String = .persacc,
        phone: String = .phone,
        numabo: String = .numabo,
        personalAcc: String = "40702810702910000312",
        bankName: String = "АО \"АЛЬФА-БАНК\" г. Москва",
        bic: String = "044525593",
        correspAcc: String = "30101810200000000593",
        payeeINN: String = "7606066274",
        kpp: String = "760601001",
        sum: String = "383296",
        purpose: String = "квитанция за ЖКУ",
        lastName: String = "",
        payerAddress: String = "Свердлова ул., д.102, кв.44",
        paymPeriod: String = "01.2024",
        category: String? = "1",
        serviceName: String = "5000",
        addAmount: String = "0"
    ) -> QRCode {
        
        let name = "АО Управляющая организация многоквартирными домами Ленинского района"
        var qrTypeStr: String = ""
        
        var rawData: [String: String] = [
            "category": category ?? "",
            "addamount": addAmount,
            "bankname": bankName,
            "personalacc": personalAcc,
            "kpp": kpp,
            "paymperiod": paymPeriod,
            "payeeinn": payeeINN,
            "servicename": serviceName,
            "purpose": purpose,
            "sum": sum,
            "name": "АО Управляющая организация многоквартирными домами Ленинского района",
            "payeraddress": payerAddress,
            "correspacc": correspAcc,
            "bic": bic,
            "lastname": lastName
        ]
        
        switch qrType {
        case .persacc:
            rawData["persacc"] = .persacc
            qrTypeStr = "persacc=\(persacc)"
            
        case .phone:
            rawData["phone"] = .phone
            qrTypeStr = "phone=\(phone)"
            
        case .numabo:
            rawData["numabo"] = .numabo
            qrTypeStr = "numabo=\(numabo)"
        }
        
        var original = "ST00012|Name=\(name)|PersonalAcc=\(personalAcc)|BankName=\(bankName)|BIC=\(bic)|CorrespAcc=\(correspAcc)|PayeeINN=\(payeeINN)|KPP=\(kpp)|Sum=\(sum)|Purpose=\(purpose)|lastName=\(lastName)|payerAddress=\(payerAddress)|\(qrTypeStr)|paymPeriod=\(paymPeriod)|ServiceName=\(serviceName)|addAmount=\(addAmount)"
        
        if let category {
            original.append("|category=\(category)")
        }
        
        return QRCode(original: original, rawData: withRawData ? rawData : [:])
    }
}

extension ParameterData {
    
    static let pdClearOutput = getParameterData(id: "IdOutput", viewType: .output)
    static let pdClearInput = getParameterData(id: "IdInput", viewType: .input)
    static let pdAccountInpFTNil = getParameterData(id: "a3_PERSONAL_ACCOUNT_1_1", viewType: .input)
    static let pdAccountInpFTPersonalAccount = getParameterData(id: "a3_PERSONAL_ACCOUNT_1_1", viewType: .input, inputFieldType: .account)
    static let pdAccountInpFTAccount = getParameterData(id: "account", viewType: .input, inputFieldType: .account)
    static let pdCode = getParameterData(id: "a3_CODE_3_1", viewType: .input)
    
    private static func getParameterData(
        id: String,
        viewType: ViewType = .input,
        title: String = "inputTitle",
        inputFieldType: inputFieldType? = nil
    ) -> ParameterData {
        
        return .init(content: nil, dataType: nil, id: id, isPrint: nil, isRequired: nil, mask: nil, maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: nil, regExp: nil, subTitle: nil, title: title, type: nil, inputFieldType: inputFieldType, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: viewType)
    }
}

private extension String {
    
    static let persacc = "502045019"
    static let phone = "+79995554433"
    static let numabo = "33694934"
    static let regExp = #"\d{5}810\d{12}|\d{5}643\d{12}$"#
}
