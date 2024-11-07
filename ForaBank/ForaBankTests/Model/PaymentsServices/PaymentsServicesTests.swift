//
//  PaymentsServicesTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 16.05.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsServicesTests: XCTestCase {
    
    // MARK: - Test internetTV
    
    func test_init_internetTVPaymentsService() throws {
        
        let internetTV = try XCTUnwrap(Payments.Service(rawValue: "internetTV"))
        
        XCTAssertEqual(internetTV, .internetTV)
    }
    
    func test_init_internetTVPaymentsOperator() throws {
        
        let internetTV = try XCTUnwrap(Payments.Operator(rawValue: "iFora||1051001"))
        
        XCTAssertEqual(internetTV, .internetTV)
    }
    
    func test_internetTV_isGeneralPaymentsCategory() {
        
        let category = Payments.Category.category(for: .internetTV)
        
        XCTAssertEqual(category, .general)
        XCTAssert(Payments.Category.general.services.contains(.internetTV))
    }
    
    func test_internetTV_shouldHavePaymentsOperators() {
        
        let service: Payments.Service = .internetTV
        
        XCTAssertEqual(service.operators, [.internetTV])
    }
    
    func test_internetTV_shouldHavePaymentsOperationTransferType() {
        
        let service: Payments.Service = .internetTV
        
        XCTAssertEqual(service.transferType, .internetTV)
    }
    
    func test_internetTV_shouldThrowForNotInternetTV() async {
        
        let sut = makeSUT()
        
        do {
            let step = try await sut.makeLocalStepNotPaymentService(
                stepIndex: 0
            )
            XCTFail("Expected error, got step \(step) instead.")
        } catch {}
    }
    
    // MARK: - Test service
    
    func test_init_servicePaymentsService() throws {
        
        let internetTV = try XCTUnwrap(Payments.Service(rawValue: "utility"))
        
        XCTAssertEqual(internetTV, .utility)
    }
    
    func test_init_servicePaymentsOperator() throws {
        
        let internetTV = try XCTUnwrap(Payments.Operator(rawValue: "iFora||1031001"))
        
        XCTAssertEqual(internetTV, .utility)
    }
    
    func test_service_isGeneralPaymentsCategory() {
        
        let category = Payments.Category.category(for: .utility)
        
        XCTAssertEqual(category, .general)
        XCTAssert(Payments.Category.general.services.contains(.utility))
    }
    
    func test_service_shouldHavePaymentsOperators() {
        
        let service: Payments.Service = .utility
        
        XCTAssertEqual(service.operators, [.utility])
    }
    
    func test_service_shouldHavePaymentsOperationTransferType() {
        
        let service: Payments.Service = .utility
        
        XCTAssertEqual(service.transferType, .utility)
    }
    
    func test_service_shouldThrowForNotInternetTV() async {
        
        let sut = makeSUT()
        
        do {
            let step = try await sut.makeLocalStepNotPaymentService(
                stepIndex: 0
            )
            XCTFail("Expected error, got step \(step) instead.")
        } catch {}
    }
    
    
    // MARK: - Local Step 0
    
    func test_localStepServices_shouldThrowForUnknownStepIndex() async {
        
        let sut = makeSUT()
        
        for step in [-1, 1] {
            do {
                _ = try await sut.makeLocalStepServices(stepIndex: step)
                XCTFail("Expected error for step \(step) but got value instead.")
            } catch {}
        }
    }
    
    func test_localStepLastPayments_shouldThrowForUnknownStepIndex() async {
        
        let sut = makeSUT()
        
        for step in [-1, 1] {
            do {
                _ = try await sut.makeLocalStepForLastPayments(stepIndex: step)
                XCTFail("Expected error for step \(step) but got value instead.")
            } catch {}
        }
    }
    
    func test_localStep0_shouldThrowOnErrorLastPaymentID() async throws {
        
        let sut = makeSUT()
        
        do {
            let step = try await sut.makeLocalStep(
                lastPaymentID: 1,
                stepIndex: 0
            )
            XCTFail("Expected error, got step \(step) instead.")
        } catch {}
    }
    
    
    func test_localStep0_shouldThrowOnEmptyPuref() async throws {
        
        let sut = makeSUT()
        
        do {
            let step = try await sut.makeLocalStep(
                puref: "",
                additionalList: nil,
                amount: 0,
                stepIndex: 0
            )
            XCTFail("Expected error, got step \(step) instead.")
        } catch {}
    }
    
    func test_localStep0_shouldThrowOnEmptyPurefFor0Step() async throws {
        
        let sut = makeSUT()
        
        do {
            let step = try await sut.paymentsProcessLocalStepServicesStep0(
                operatorCode: "",
                additionalList: nil,
                amount: 0, 
                productId: nil,
                isSingle: true,
                source: nil
            )
            
            XCTFail("Expected error, got step \(step) instead.")
        } catch {}
    }
    
    func test_localStep0_shouldThrowOnEmptyProductsInternetTV() async throws {
        
        let sut = makeSUT([(.card, 0)])
        
        do {
            let step = try await sut.makeLocalStepForInternetTV(stepIndex: 0)
            
            XCTFail("Expected error, got step \(step) instead.")
        } catch {}
    }
    
    func test_localStep0_shouldThrowOnEmptyProductsГtility() async throws {
        
        let sut = makeSUT([(.card, 0)])
        
        do {
            let step = try await sut.makeLocalStepForServices(stepIndex: 0)
            
            XCTFail("Expected error, got step \(step) instead.")
        } catch {}
    }
    
    func test_localStep0_shouldThrowOnErrorPuref() async throws {
        
        let sut = makeSUT()
        
        do {
            let step = try await sut.makeLocalStep(
                puref: "iFora||111",
                additionalList: nil,
                amount: 0,
                stepIndex: 0
            )
            
            XCTFail("Expected error, got step \(step) instead.")
        } catch {}
    }
    
    func test_localStep0_shouldSetBackStageToRemoteStartInternetTV() async throws {
        
        let sut = makeSUT()
        let step = try await sut.makeLocalStepForInternetTV(stepIndex: 0)
        
        XCTAssertEqual(step.back.stage, .remote(.start))
    }
    
    func test_localStep0_shouldSetBackStageToRemoteStartServices() async throws {
        
        let sut = makeSUT()
        let step = try await sut.makeLocalStepForServices(stepIndex: 0)
        
        XCTAssertEqual(step.back.stage, .remote(.start))
    }
    
    func test_localStep0_shouldSetBackProcessedToNilInternetTV() async throws {
        
        let sut = makeSUT()
        let step = try await sut.makeLocalStepForInternetTV(stepIndex: 0)
        
        XCTAssertNil(step.back.processed)
    }
    
    func test_localStep0_shouldSetBackProcessedToNilServices() async throws {
        
        let sut = makeSUT()
        let step = try await sut.makeLocalStepForServices(stepIndex: 0)
        
        XCTAssertNil(step.back.processed)
    }
    
    func test_localStep0_shouldSetParameters() async throws {
        
        let sut = makeSUT()
        let step = try await sut.makeLocalStepForInternetTV(stepIndex: 0)
        let parameterNames = await sut.parameterNameForRepresentationInternetTV()
        
        let expectedIDs: [String] = [
            Payments.Parameter.Identifier.operator.rawValue,
            Payments.Parameter.Identifier.header.rawValue,
            Payments.Parameter.Identifier.product.rawValue
        ]
        
        XCTAssertEqual(Set(step.parameters.map(\.id)), Set(expectedIDs + parameterNames))
    }
    
    func test_localStep0_shouldSetFrontVisibleNoSingleInternetTV() async throws {
        
        let sut = makeSUT()
        let step = try await sut.makeLocalStepForInternetTV(stepIndex: 0)
        let parameterNames = sut.parameterNameForVisibleInternetTV()
        
        let expectedIDs: [String] = [
            Payments.Parameter.Identifier.header.rawValue
        ]
        
        XCTAssertEqual(Set(step.front.visible), Set(expectedIDs + parameterNames))
    }
    
    func test_localStep0_shouldSetFrontVisibleSingleWithProductAndSumInternetTV() async throws {
        
        let sut = makeSUT()
        let step = try await sut.makeLocalStepForInternetTV(stepIndex: 0, isSingle: true)
        let parameterNames = sut.parameterNameForVisibleInternetTV()
        
        let expectedIDs: [String] = [
            Payments.Parameter.Identifier.header.rawValue,
            Payments.Parameter.Identifier.amount.rawValue,
            Payments.Parameter.Identifier.product.rawValue
        ]
        
        XCTAssertEqual(Set(step.front.visible), Set(expectedIDs + parameterNames))
    }
    
    func test_localStep0_shouldSetFrontVisibleNoSingleServices() async throws {
        
        let sut = makeSUT()
        let step = try await sut.makeLocalStepForServices(stepIndex: 0)
        let parameterName = sut.parameterNameForVisibleServices()
        
        let expectedIDs: [String] = [
            Payments.Parameter.Identifier.header.rawValue
        ]
        
        XCTAssertEqual(Set(step.front.visible), Set(expectedIDs + parameterName))
    }
    
    func test_localStep0_shouldSetFrontVisibleSingleWithProductAndSumServices() async throws {
        
        let sut = makeSUT()
        let step = try await sut.makeLocalStepForServices(stepIndex: 0, isSingle: true)
        let parameterName = sut.parameterNameForVisibleServices()
        
        let expectedIDs: [String] = [
            Payments.Parameter.Identifier.header.rawValue,
            Payments.Parameter.Identifier.amount.rawValue,
            Payments.Parameter.Identifier.product.rawValue
        ]
        
        XCTAssertEqual(Set(step.front.visible), Set(expectedIDs + parameterName))
    }
    
    func test_localStep0_shouldSetBackRequired() async throws {
        
        let sut = makeSUT()
        let step = try await sut.makeLocalStepForInternetTV(stepIndex: 0)
        let parameterNames = sut.parameterNameForRequiredInternetTV()
        
        let expectedIDs: [String] = [
            Payments.Parameter.Identifier.product.rawValue
        ]
        
        XCTAssertEqual(Set(step.back.required), Set(expectedIDs + parameterNames))
    }
    
    // MARK: - paymentsServicesStepExcludingParameters
    
    func test_paymentsServicesStepExcludingParameters_containsExcludingParameters() async throws {
        
        let sut = makeSUT()
        
        let excludingParameters = try sut.paymentsServicesStepExcludingParameters(response: transferAnywayResponse)
        
        XCTAssertEqual(Set(excludingParameters), Set(["a3_NUMBER_1_21", "AFResponse"]))
    }
    
    func test_paymentsServicesStepRequired_notContainsRequiredParameters() async throws {
        
        let sut = makeSUT()
        
        let excludingParameters = try sut.paymentsServicesStepExcludingParameters(response: transferAnywayResponse)
        
        XCTAssertNotEqual(Set(excludingParameters), Set(["a3_NUMBER_1_2"]))
    }
    
    //MARK: - dataByOperation
    func test_dataByOperation_shouldSetValues() async throws {
        
        let sut = makeSUT()
        let lastPayment: PaymentServiceData = sut.latestPayments.value.first as! PaymentServiceData
        
        let operation = Payments.Operation(
            service: .internetTV,
            source: .latestPayment(lastPayment.id)
        )
        
        let resault = try sut.dataByOperation(operation)
        
        XCTAssertEqual(resault.puref, lastPayment.puref)
        XCTAssertEqual(resault.amount, lastPayment.amount)
        XCTAssertEqual(resault.additionalList, lastPayment.additionalList)
    }
    
    func test_dataByOperation_shouldThrowOnErrorLastPaymentId() async throws {
        
        let sut = makeSUT()
        
        let operation = Payments.Operation(
            service: .internetTV,
            source: .latestPayment(1)
        )
        
        do {
            _ = try sut.dataByOperation(operation)
            
            XCTFail("Expected error")
        } catch {}
    }
    
    func test_dataByOperation_shouldThrowForMissingSource() async {
        
        let sut = makeSUT()
        
        let operation = Payments.Operation(
            service: .internetTV,
            source: .template(1)
        )
        
        do {
            _ = try sut.dataByOperation(operation)
            
            XCTFail("Expected error")
        } catch {}
    }
    
    // MARK: - accountNumberForPayment
    
    func test_shouldSetAccountNumberForPayment() {
        
        if let qrCode = QRCode(string: separatedStringWithAccount) {
            
            let sut = makeSUT()
            
            let parametrName = sut.accountNumberForPayment(qrCode: qrCode)
            
            XCTAssertEqual(parametrName, "110110581")
        }
    }
    
    func test_shouldSetPhoneNumberForPayment() {
        
        if let qrCode = QRCode(string: separatedStringWithPhone) {
            
            let sut = makeSUT()
            
            let parametrName = sut.accountNumberForPayment(qrCode: qrCode)
            
            XCTAssertEqual(parametrName, "681361979")
        }
    }
    
    func test_shouldSetAbNumberForPayment() {
        
        if let qrCode = QRCode(string: separatedStringWithAbNum) {
            
            let sut = makeSUT()
            
            let parametrName = sut.accountNumberForPayment(qrCode: qrCode)
            
            XCTAssertEqual(parametrName, "33694934")
        }
    }
    
    func test_shouldSetEmptyValueForPayment() {
        
        if let qrCode = QRCode(string: separatedString) {
            
            let sut = makeSUT()
            
            let parametrName = sut.accountNumberForPayment(qrCode: qrCode)
            
            XCTAssertEqual(parametrName, "")
        }
    }
    
    //MARK: - test header
    
    func test_header_ifAvtodorContractSetAvtodorGroupTitleSubtitleNil(){
        
        let sut = makeSUT()
        
        let header = sut.header(
            operatorCode: Purefs.avtodorContract,
            operatorValue: .test(
                code: Purefs.avtodorContract,
                name: "test",
                parentCode: Purefs.transport
            ),
            source: nil
        )
        
        XCTAssertNoDiff(header.title, .avtodorGroupTitle)
        XCTAssertNil(header.subtitle)
    }

    func test_header_ifAvtodorTransponderSetAvtodorGroupTitleSubtitleNil(){
        
        let sut = makeSUT()
        
        let header = sut.header(
            operatorCode: Purefs.avtodorTransponder,
            operatorValue: .test(
                code: Purefs.avtodorTransponder,
                name: "test",
                parentCode: Purefs.transport
            ),
            source: nil
        )
        
        XCTAssertNoDiff(header.title, .avtodorGroupTitle)
        XCTAssertNil(header.subtitle)
    }

    func test_header_isNotAvtodorShouldSetTitleByName(){
        
        let sut = makeSUT()
        
        let header = sut.header(
            operatorCode: "iFora||5576",
            operatorValue: .test(
                code: "iFora||5576",
                name: "test",
                parentCode: "111",
                synonymList: ["subtitle"]
            ),
            source: nil
        )
        
        XCTAssertNoDiff(header.title, "test")
        XCTAssertNoDiff(header.subtitle, "subtitle")
    }

    // MARK: - Helpers
    
    private func makeSUT(
        _ counts: ProductTypeCounts = [(.card, 1)],
        currencies: [CurrencyData] = [.rub],
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sut: Model = .mockWithOperatorsList
        
        sut.products.value = makeProductsData(counts)
        sut.currencyList.value = currencies
        sut.latestPayments.value = lastPayments()
        
        // TODO: activate this check after Model refactoring
        // trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

let separatedStringWithAccount = """
             ST00012|Name=ПАО "Калужская сбытовая компания"|PersonalAcc=40702810600180000156|BankName=Тульский филиал АБ "РОССИЯ"|BIC=047003764|CorrespAcc=30101810600000000764|PersAcc=110110581|Sum=66671|Purpose= лс 110110581 ЭЭ|PayeeINN=4029030252|KPP=402801001|TechCode=02|Category=1|KSK_PeriodPok=202208|KSK_Type=1|Amount=6835|Any=123
             """

let separatedStringWithPhone = """
                        ST00012|Name=ПАО МГТС|PersonalAcc=40702810800020106631|BankName= СБЕРБАНК РОССИИ ПАО|BIC=044525225|CorrespAcc=30101810400000000225|PayeeINN=7710016640|phone=681361979|flat=716|sum=000
                        """

let separatedStringWithAbNum = """
                            ST00012|Name=АО Московская телекоммуникационная корпорация|PersonalAcc=40702810038180120552|BankName=ПАО СБЕРБАНК|BIC=044525225|CorrespAcc=30101810400000000225|PayeeINN=7717020170|KPP=772601001|numAbo=33694934|Contract=33694934|Purpose=по договору № 33694934|ServiceName=114323159985|Sum=57200
                        """

let separatedString = """
                            ST00012|Name=АО Московская телекоммуникационная корпорация|PersonalAcc=40702810038180120552|BankName=ПАО СБЕРБАНК|BIC=044525225|CorrespAcc=30101810400000000225|PayeeINN=7717020170|KPP=772601001|Contract=33694934|Purpose=по договору № 33694934|ServiceName=114323159985|Sum=57200
                        """

let parameterListForNextStep = [
    ParameterData.init(content: nil, dataType: "%String", id: "a3_NUMBER_1_2", isPrint: false, isRequired: true, mask: nil, maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: nil, title: "Номер телефона +7", type: "INPUT", inputFieldType: nil, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .input),
    ParameterData.init(content: nil, dataType: "%String", id: "a3_NUMBER_1_21", isPrint: false, isRequired: false, mask: nil, maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: false, regExp: "^\\d{10}$", subTitle: nil, title: "Номер телефона", type: "INPUT", inputFieldType: nil, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .input),
]

let transferAnywayResponse = TransferAnywayResponseData(amount: 100, creditAmount: 100, currencyAmount: Currency(description: "RUB"), currencyPayee: Currency(description: "RUB"), currencyPayer: Currency(description: "RUB"), currencyRate: 87.5, debitAmount: 100, fee: 5, needMake: true, needOTP: false, payeeName: "Иван Иванович", documentStatus: .complete, paymentOperationDetailId: 1, additionalList: [], finalStep: true, infoMessage: "string", needSum: false, printFormType: nil, parameterListForNextStep: parameterListForNextStep, scenario: .ok)

extension Model {
    
    static let mockWithOperatorsList: Model = {
        
        let bundle = Bundle(for: Model.self)
        
        let localAgentDataStub: [String: Data] = [
            "Array<OperatorGroupData>": .operatorGroupData,
        ]
        let localAgent = LocalAgentStub(stub: localAgentDataStub)
        
        let model = Model(sessionAgent: SessionAgentEmptyMock(), serverAgent: ServerAgentEmptyMock(), localAgent: localAgent, keychainAgent: KeychainAgentMock(), settingsAgent: SettingsAgentMock(), biometricAgent: BiometricAgentMock(), locationAgent: LocationAgentMock(), contactsAgent: ContactsAgentMock(), cameraAgent: CameraAgentMock(), imageGalleryAgent: ImageGalleryAgentMock(), networkMonitorAgent: NetworkMonitorAgentMock())
        
        return model
    }()
    
    // MARK: - DSL
    
    func makeLocalStepServices(stepIndex: Int) async throws -> Payments.Operation.Step {
        
        let operation = Payments.Operation(
            service: .internetTV,
            source: .servicePayment(
                puref: "",
                additionalList: nil,
                amount: 0, 
                productId: nil)
        )
        
        return try await paymentsProcessLocalStepServices(
            operation,
            for: stepIndex
        )
    }
    
    func makeLocalStepForLastPayments(stepIndex: Int) async throws -> Payments.Operation.Step {
        
        let operation = Payments.Operation(
            service: .internetTV,
            source: .latestPayment(0)
        )
        
        return try await paymentsProcessLocalStepServices(
            operation,
            for: stepIndex
        )
    }
    
    func makeLocalStepNotPaymentService(stepIndex: Int) async throws -> Payments.Operation.Step {
        
        let operation = Payments.Operation(
            service: .mobileConnection
        )
        
        return try await paymentsProcessLocalStepServices(
            operation,
            for: stepIndex
        )
    }
    
    func makeLocalStepForInternetTV(stepIndex: Int, isSingle: Bool = false) async throws -> Payments.Operation.Step {
        
        return try await paymentsProcessLocalStepServicesStep0(
            operatorCode: "iFora||5576",
            additionalList: nil,
            amount: 0, 
            productId: nil,
            isSingle: isSingle,
            source: nil)
        
    }
    
    func makeLocalStepForServices(stepIndex: Int, isSingle: Bool = false) async throws -> Payments.Operation.Step {
        
        return try await paymentsProcessLocalStepServicesStep0(
            operatorCode: "iFora||C31",
            additionalList: nil,
            amount: 0,
            productId: nil,
            isSingle: isSingle,
            source: nil)
    }
    
    func makeLocalStep(
        puref: String,
        additionalList: [PaymentServiceData.AdditionalListData]?,
        amount: Double,
        isSingle: Bool = false,
        stepIndex: Int
    ) async throws -> Payments.Operation.Step {
        
        let operation = Payments.Operation(
            service: .internetTV,
            source: .servicePayment(
                puref: puref,
                additionalList: additionalList,
                amount: amount, 
                productId: nil
            )
        )
        
        return try await paymentsProcessLocalStepServices(
            operation,
            for: stepIndex
        )
    }
    
    func makeLocalStep(
        lastPaymentID: Int,
        isSingle: Bool = false,
        stepIndex: Int
    ) async throws -> Payments.Operation.Step {
        
        let operation = Payments.Operation(
            service: .internetTV,
            source: .latestPayment(lastPaymentID)
        )
        
        return try await paymentsProcessLocalStepServices(
            operation,
            for: stepIndex
        )
    }
    
    // MARK: - InternetTV
    func parameterListForInternetTV() -> [ParameterData] {
        
        if let operationData = dictionaryAnywayOperator(for: "iFora||5576") {
            return operationData.parameterList
        }
        
        return .init()
    }
    
    func parameterNameForRepresentationInternetTV() async -> [String] {
        
        var names = [String]()
        
        for data in parameterListForInternetTV() {
            
            let parameter = await paymentsParameterRepresentableServices(
                additionalList: nil,
                parameterData: data
            )
            if let id = parameter?.id {
                names.append(id)
            }
        }
        
        return names
    }
    
    func parameterNameForRequiredInternetTV() -> [String] {
        
        return parameterListForInternetTV().compactMap { paymentsParameterRequired(parameterData: $0 ) ?? nil }
    }
    
    func parameterNameForVisibleInternetTV() -> [String] {
        
        return parameterListForInternetTV().compactMap { paymentsParameterVisible(parameterData: $0 ) ?? nil }
    }
    
    // MARK: - Service
    
    func parameterListForServices() -> [ParameterData] {
        
        if let operationData = dictionaryAnywayOperator(for: "iFora||C31") {
            return operationData.parameterList
        }
        
        return .init()
    }
    
    func parameterNameForRepresentationServices() async -> [String] {
        
        var names = [String]()
        
        for data in parameterListForServices() {
            
            let parameter = await paymentsParameterRepresentableServices(
                additionalList: nil,
                parameterData: data
            )
            if let id = parameter?.id {
                names.append(id)
            }
        }
        
        return names
    }
    
    func parameterNameForRequiredServices() -> [String] {
        
        return parameterListForServices().compactMap { paymentsParameterRequired(parameterData: $0 ) ?? nil }
    }
    
    func parameterNameForVisibleServices() -> [String] {
        
        return parameterListForServices().compactMap { paymentsParameterVisible(parameterData: $0 ) ?? nil }
    }
}

func lastPayments() -> [PaymentServiceData] {
    
    let date = Date.dateUTC(with: 1653570551608)
    
    let data = PaymentServiceData(additionalList: [.init(fieldTitle: "Лицевой счет у Получателя",
                                                         fieldName: "a3_NUMBER_1_2",
                                                         fieldValue: "1234567890",
                                                         svgImage: "string")],
                                  amount: 100,
                                  date: date,
                                  paymentDate: "21.12.2021 11:04:26",
                                  puref: "iFora||4285",
                                  type: .internet,
                                  lastPaymentName: nil)
    
    return [data]
}
