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
    
//    func test_getValue_forEmptyQRCode_returnsEmptyString() {
//        let parameterData: ParameterData = .pdClearOutput
//        let qrCode: QRCode = .qrPersAcc
//       let model = makeSUT()
//        let value = model.getValue(for: parameterData, qrCode: qrCode)
//       
//       XCTAssertEqual(value, "")
//     }
    func test_additionalList_PDviewTypeOutput_returnsNil() {
        
        let model = makeSUT()
        let parameterData: ParameterData = .pdClearOutput
        let qrCode: QRCode = .qrPersAcc
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        let value = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = value?.first?.fieldValue
       XCTAssertEqual(res, nil)
     }
    func test_additionalList_PDviewTypeInput_returnsEmpty() {
        
        let model = makeSUT()
        let parameterData: ParameterData = .pdClearInput
        let qrCode: QRCode = .qrPersAcc
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        let value = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = value?.first?.fieldValue
       XCTAssertEqual(res, "")
     }
    func test_additionalList_AccountinputFieldTypeNil_returnsEmpty() {
        let parameterData: ParameterData = .pdAccountInpFTNil
        let qrCode: QRCode = .qrPersAcc
       let model = makeSUT()
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        let value = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = value?.first?.fieldValue
       XCTAssertEqual(res, "")
     }
    
    func test_additionalList_AccountinputFieldTypeAccount_QRwithoutRawData_returnsEmpty() {
        let parameterData: ParameterData = .pdAccountInpFTAccount
        let qrCode: QRCode = .qrWithoutAccountNumberForPayment
       let model = makeSUT()
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        let value = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = value?.first?.fieldValue
       XCTAssertEqual(res, "")
     }
    
    func test_additionalList_AccountinputFieldTypeAccount_QRwithoutRawData_accountNumberForPaymentpersacc() {
        let parameterData: ParameterData = .pdAccountInpFTAccount
        let qrCode: QRCode = .qrPersAcc
       let model = makeSUT()
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        let value = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = value?.first?.fieldValue
       XCTAssertEqual(res, qrCode.rawData["persacc"])
     }
    func test_additionalList_AccountinputFieldTypeAccount_QRwithoutRawData_accountNumberForPaymentphone() {
        let parameterData: ParameterData = .pdAccountInpFTAccount
        let qrCode: QRCode = .qrPhone
       let model = makeSUT()
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        let value = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = value?.first?.fieldValue
       XCTAssertEqual(res, qrCode.rawData["phone"])
     }
    func test_additionalList_AccountinputFieldTypeAccount_QRwithoutRawData_accountNumberForPaymentnumabo() {
        let parameterData: ParameterData = .pdAccountInpFTAccount
        let qrCode: QRCode = .qrNumAbo
       let model = makeSUT()
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        let value = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = value?.first?.fieldValue
       XCTAssertEqual(res, qrCode.rawData["numabo"])
     }
    
    
    func test_additionalList_ParameterDataCodeWithCategory_retursRawData() {
        let parameterData: ParameterData = .pdCode
        let qrCode: QRCode = .qrPersAcc
       let model = makeSUT()
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        let value = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = value?.first?.fieldValue
        let qqqr = qrCode.rawData["category"]
       XCTAssertEqual(res, "1")
     }
    func test_additionalList_ParameterDataCodeWithoutCategory_retursEmptyString() {
        let parameterData: ParameterData = .pdCode
        let qrCode: QRCode = .qrPersAccCategoryNil
       let model = makeSUT()
        let operatorData: OperatorGroupData.OperatorData = .test(code: "code", name: "name", parameterList: [parameterData], parentCode: "parentCode")
        let value = model.additionalList(for: operatorData, qrCode: qrCode)
        let res = value?.first?.fieldValue
        let qqqr = qrCode.rawData["category"]
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
    
    static let qrPersAcc: Self = .init(
        original: "ST00012|Name=АО Управляющая организация многоквартирными домами Ленинского района|PersonalAcc=40702810702910000312|BankName=АО  \"АЛЬФА-БАНК\" г. Москва|BIC=044525593|CorrespAcc=30101810200000000593|PayeeINN=7606066274|KPP=760601001|Sum=383296|Purpose=квитанция за ЖКУ|lastName=|payerAddress=Свердлова ул., д.102, кв.44|persAcc=502045019|paymPeriod=01.2024|category=1|ServiceName=5000|addAmount=0",
        rawData: ["category": "1", "addamount": "0", "bankname": "АО  \"АЛЬФА-БАНК\" г. Москва", "personalacc": "40702810702910000312", "kpp": "760601001", "persacc": "502045019", "paymperiod": "01.2024", "payeeinn": "7606066274", "servicename": "5000", "purpose": "квитанция за ЖКУ", "sum": "383296", "name": "АО Управляющая организация многоквартирными домами Ленинского района", "payeraddress": "Свердлова ул., д.102, кв.44", "correspacc": "30101810200000000593", "bic": "044525593", "lastname": ""]
    )
    
    static let qrPersAccCategoryNil: Self = .init(
        original: "ST00012|Name=АО Управляющая организация многоквартирными домами Ленинского района|PersonalAcc=40702810702910000312|BankName=АО  \"АЛЬФА-БАНК\" г. Москва|BIC=044525593|CorrespAcc=30101810200000000593|PayeeINN=7606066274|KPP=760601001|Sum=383296|Purpose=квитанция за ЖКУ|lastName=|payerAddress=Свердлова ул., д.102, кв.44|persAcc=502045019|paymPeriod=01.2024|ServiceName=5000|addAmount=0",
        rawData: ["addamount": "0", "bankname": "АО  \"АЛЬФА-БАНК\" г. Москва", "personalacc": "40702810702910000312", "kpp": "760601001", "persacc": "502045019", "paymperiod": "01.2024", "payeeinn": "7606066274", "servicename": "5000", "purpose": "квитанция за ЖКУ", "sum": "383296", "name": "АО Управляющая организация многоквартирными домами Ленинского района", "payeraddress": "Свердлова ул., д.102, кв.44", "correspacc": "30101810200000000593", "bic": "044525593", "lastname": ""]
    )
    
    static let qrWithoutAccountNumberForPayment: Self = .init(
        original: "ST00012|Name=АО Управляющая организация многоквартирными домами Ленинского района|PersonalAcc=40702810702910000312|BankName=АО  \"АЛЬФА-БАНК\" г. Москва|BIC=044525593|CorrespAcc=30101810200000000593|PayeeINN=7606066274|KPP=760601001|Sum=383296|Purpose=квитанция за ЖКУ|lastName=|payerAddress=Свердлова ул., д.102, кв.44|persAcc=502045019|paymPeriod=01.2024|category=1|ServiceName=5000|addAmount=0",
        rawData: [:]
    )
    
    static let qrPhone: Self = .init(
        original: "ST00012|Name=АО Управляющая организация многоквартирными домами Ленинского района|PersonalAcc=40702810702910000312|BankName=АО  \"АЛЬФА-БАНК\" г. Москва|BIC=044525593|CorrespAcc=30101810200000000593|PayeeINN=7606066274|KPP=760601001|Sum=383296|Purpose=квитанция за ЖКУ|lastName=|payerAddress=Свердлова ул., д.102, кв.44|phone=+79995554433|paymPeriod=01.2024|category=1|ServiceName=5000|addAmount=0",
        rawData: ["category": "1", "addamount": "0", "bankname": "АО  \"АЛЬФА-БАНК\" г. Москва", "personalacc": "40702810702910000312", "kpp": "760601001", "phone": "+79995554433", "paymperiod": "01.2024", "payeeinn": "7606066274", "servicename": "5000", "purpose": "квитанция за ЖКУ", "sum": "383296", "name": "АО Управляющая организация многоквартирными домами Ленинского района", "payeraddress": "Свердлова ул., д.102, кв.44", "correspacc": "30101810200000000593", "bic": "044525593", "lastname": ""]
    )
    
    static let qrNumAbo: Self = .init(
        original: "ST00012|Name=АО Управляющая организация многоквартирными домами Ленинского района|PersonalAcc=40702810702910000312|BankName=АО  \"АЛЬФА-БАНК\" г. Москва|BIC=044525593|CorrespAcc=30101810200000000593|PayeeINN=7606066274|KPP=760601001|Sum=383296|Purpose=квитанция за ЖКУ|lastName=|payerAddress=Свердлова ул., д.102, кв.44|numabo=33694934|paymPeriod=01.2024|category=1|ServiceName=5000|addAmount=0",
        rawData: ["category": "1", "addamount": "0", "bankname": "АО  \"АЛЬФА-БАНК\" г. Москва", "personalacc": "40702810702910000312", "kpp": "760601001", "numabo": "33694934", "paymperiod": "01.2024", "payeeinn": "7606066274", "servicename": "5000", "purpose": "квитанция за ЖКУ", "sum": "383296", "name": "АО Управляющая организация многоквартирными домами Ленинского района", "payeraddress": "Свердлова ул., д.102, кв.44", "correspacc": "30101810200000000593", "bic": "044525593", "lastname": ""]
    )
}

extension ParameterData {
    
    static let pdClearOutput: ParameterData = .init(content: nil, dataType: nil, id: "IDoutput", isPrint: nil, isRequired: nil, mask: nil, maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: nil, regExp: nil, subTitle: nil, title: "inputTitle", type: nil, inputFieldType: nil, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .output)
    
    static let pdClearInput: ParameterData = .init(content: nil, dataType: nil, id: "IDinput", isPrint: nil, isRequired: nil, mask: nil, maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: nil, regExp: nil, subTitle: nil, title: "inputTitle", type: nil, inputFieldType: nil, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .input)
    
    static let pdAccountInpFTNil: ParameterData = .init(content: nil, dataType: nil, id: "a3_PERSONAL_ACCOUNT_1_1", isPrint: nil, isRequired: nil, mask: nil, maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: nil, regExp: nil, subTitle: nil, title: "inputTitle", type: nil, inputFieldType: nil, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .input)
    
    static let pdAccountInpFTAccount: ParameterData = .init(content: nil, dataType: nil, id: "a3_PERSONAL_ACCOUNT_1_1", isPrint: nil, isRequired: nil, mask: nil, maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: nil, regExp: nil, subTitle: nil, title: "inputTitle", type: nil, inputFieldType: .account, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .input)
    
    static let pdCode: ParameterData = .init(content: nil, dataType: nil, id: "a3_CODE_3_1", isPrint: nil, isRequired: nil, mask: nil, maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: nil, regExp: nil, subTitle: nil, title: "inputTitle", type: nil, inputFieldType: nil, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .input)
}
