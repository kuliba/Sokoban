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
    
    func test_additionalList_PDviewTypeOutput_returnsNil() {
        
        let model = makeSUT()
        let parameterData: ParameterData = .pdClearOutput
        let qrCode: QRCode = .qrPersAcc
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        
        let list = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = list?.first?.fieldValue
        
        XCTAssertEqual(res, nil)
    }
    
    func test_additionalList_PDviewTypeInput_returnsEmpty() {
        
        let model = makeSUT()
        let parameterData: ParameterData = .pdClearInput
        let qrCode: QRCode = .qrPersAcc
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        
        let list = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = list?.first?.fieldValue
        
        XCTAssertEqual(res, "")
    }
    
    func test_additionalList_AccountinputFieldTypeNil_returnsEmpty() {
        
        let model = makeSUT()
        let parameterData: ParameterData = .pdAccountInpFTNil
        let qrCode: QRCode = .qrPersAcc
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        
        let list = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = list?.first?.fieldValue
        
        XCTAssertEqual(res, "")
        
    }
    
    func test_additionalList_AccountinputFieldTypeAccount_QRwithoutRawData_returnsEmpty() {
        
        let model = makeSUT()
        let parameterData: ParameterData = .pdAccountInpFTAccount
        let qrCode: QRCode = .qrWithoutAccountNumberForPayment
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        
        let list = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = list?.first?.fieldValue
        
        XCTAssertEqual(res, "")
    }
    
    func test_additionalList_AccountinputFieldTypePersonalAccount_accountNumberForPaymentpersacc() {
        
        let model = makeSUT()
        let parameterData: ParameterData = .pdAccountInpFTPersonalAccount
        let qrCode: QRCode = .qrPersAcc
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        
        let list = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = list?.first?.fieldValue
        
        XCTAssertEqual(res, qrCode.rawData["persacc"])
    }
    
    func test_additionalList_AccountinputFieldTypeAccount_QRwithRawData_222() {
        
        let model = makeSUT()
        let parameterData: ParameterData = .pdAccountInpFTAccount
        let qrCode: QRCode = .qrPersAcc
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        
        let list = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = list?.first?.fieldValue
        
        XCTAssertEqual(res, qrCode.rawData["persacc"])
    }
    
    func test_additionalList_AccountinputFieldTypeAccount_QRwithoutRawData_accountNumberForPaymentphone() {
        
        let model = makeSUT()
        let parameterData: ParameterData = .pdAccountInpFTAccount
        let qrCode: QRCode = .qrPhone
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        
        let list = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = list?.first?.fieldValue
        
        XCTAssertEqual(res, qrCode.rawData["phone"])
    }
    
    func test_additionalList_AccountinputFieldTypeAccount_QRwithoutRawData_accountNumberForPaymentnumabo() {
        
        let model = makeSUT()
        let parameterData: ParameterData = .pdAccountInpFTAccount
        let qrCode: QRCode = .qrNumAbo
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        let list = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = list?.first?.fieldValue
        
        XCTAssertEqual(res, qrCode.rawData["numabo"])
    }
    
    func test_additionalList_ParameterDataCodeWithCategory_retursRawData() {
        
        let model = makeSUT()
        let parameterData: ParameterData = .pdCode
        let qrCode: QRCode = .qrPersAcc
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        
        let list = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = list?.first?.fieldValue
        
        XCTAssertEqual(res, "1")
    }
    
    func test_additionalList_ParameterDataCodeWithoutCategory_retursEmptyString() {
        
        let model = makeSUT()
        let parameterData: ParameterData = .pdCode
        let qrCode: QRCode = .qrPersAccCategoryNil
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        
        let list = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = list?.first?.fieldValue
        
        XCTAssertEqual(res, "")
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
            rawData["persacc"] = "502045019"
            qrTypeStr = "persacc=502045019"
            
        case .phone:
            rawData["phone"] = "+79995554433"
            qrTypeStr = "phone=+79995554433"
            
        case .numabo:
            rawData["numabo"] = "33694934"
            qrTypeStr = "numabo=33694934"
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
