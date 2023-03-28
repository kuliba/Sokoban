//
//  Model+PaymentsTransferMobileConnectionTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 21.02.2023.
//

@testable import ForaBank
import XCTest

#if MOCK
final class Model_PaymentsTransferMobileConnectionTests: XCTestCase {
    
    // MARK: - Payments Helpers
    
    // MARK: - makeTransferPayload
    
    func test_makeTransferPayload_shouldThrow_onEmptyParameters() throws {
        
        let parameters: [PaymentsParameterRepresentable] = []
        let payload: [DaDataPhoneData] = [.iFora4285]
        
        XCTAssertThrowsError(
            try parameters.makeTransferPayload(for: payload, currency: "RUB", operatorID: { $0 })
        ) {  error in
            XCTAssertEqual(error as? MCError, .init("Expected ParameterAmount."))
        }
    }
    
    func test_makeTransferPayload_shouldThrow_onMissingParameterProduct() throws {
        
        let parameters: [PaymentsParameterRepresentable] = [makeParameterAmount()]
        let payload: [DaDataPhoneData] = [.iFora4285]
        
        XCTAssertThrowsError(
            try parameters.makeTransferPayload(for: payload, currency: "RUB", operatorID: { $0 })
        ) {  error in
            XCTAssertEqual(error as? MCError, .init("Expected ParameterProduct."))
        }
    }
    
    func test_makeTransferPayload_shouldThrow_onMissingParameterAmount() throws {
        
        let parameters: [PaymentsParameterRepresentable] = [makeParameterProduct()]
        let payload: [DaDataPhoneData] = [.iFora4285]
        
        XCTAssertThrowsError(
            try parameters.makeTransferPayload(for: payload, currency: "RUB", operatorID: { $0 })
        ) {  error in
            XCTAssertEqual(error as? MCError, .init("Expected ParameterAmount."))
        }
    }
    
    func test_makeTransferPayload_shouldThrow_onEmptyPayload() throws {
        
        let parameters: [PaymentsParameterRepresentable] = [
            makeParameterProduct(), makeParameterAmount()
        ]
        let payload: [DaDataPhoneData] = []
        
        XCTAssertThrowsError(
            try parameters.makeTransferPayload(for: payload, currency: "RUB", operatorID: { $0 })
        ) {  error in
            XCTAssertEqual(error as? MCError, .init("Payload expected to be non empty."))
        }
    }
    
    func test_makeTransferPayload_shouldThrow_onMissingOperator() throws {
        
        let parameters: [PaymentsParameterRepresentable] = [
            makeParameterProduct(), makeParameterAmount()
        ]
        let payload: [DaDataPhoneData] = [.iFora4285]
        
        XCTAssertThrowsError(
            try parameters.makeTransferPayload(for: payload, currency: "RUB", operatorID: { _ in nil })
        ) {  error in
            XCTAssertEqual(error as? MCError, .init("Expected to have operator in operator dictionary."))
        }
    }
    
    func test_makeTransferPayload_shouldCreateTransferPayload_iFora4285() throws {
        
        let parameters: [PaymentsParameterRepresentable] = [
            makeParameterProduct(), makeParameterAmount()
        ]
        let payload: [DaDataPhoneData] = [.iFora4285]
        
        let transferPayload = try parameters.makeTransferPayload(for: payload, currency: "RUB", operatorID: { $0 })
        
        XCTAssertEqual(transferPayload.amount, 99.0)
        XCTAssertEqual(transferPayload.check, false)
        XCTAssertEqual(transferPayload.puref, "iFora||4285")
        XCTAssertEqual(transferPayload.currencyAmount, "RUB")
        
        XCTAssertEqual(transferPayload.payer.cardId, 10000235538)
        XCTAssertEqual(transferPayload.payer.cardNumber, nil)
        XCTAssertEqual(transferPayload.payer.accountId, nil)
        XCTAssertEqual(transferPayload.payer.accountNumber, nil)
        XCTAssertEqual(transferPayload.payer.phoneNumber, nil)
        
        XCTAssertEqual(transferPayload.additional.first?.fieldid, 1)
        XCTAssertEqual(transferPayload.additional.first?.fieldname, "iFora||4285")
        XCTAssertEqual(transferPayload.additional.first?.fieldvalue, "+7 903 999-99-99")
    }
    
    func test_makeTransferPayload_shouldCreateTransferPayload_iFora4286() throws {
        
        let parameters: [PaymentsParameterRepresentable] = [
            makeParameterProduct(), makeParameterAmount()
        ]
        let payload: [DaDataPhoneData] = [.iFora4286]
        
        let transferPayload = try parameters.makeTransferPayload(for: payload, currency: "RUB", operatorID: { $0 })
        
        XCTAssertEqual(transferPayload.amount, 99.0)
        XCTAssertEqual(transferPayload.check, false)
        XCTAssertEqual(transferPayload.puref, "iFora||4286")
        XCTAssertEqual(transferPayload.currencyAmount, "RUB")
        
        XCTAssertEqual(transferPayload.payer.cardId, 10000235538)
        XCTAssertEqual(transferPayload.payer.cardNumber, nil)
        XCTAssertEqual(transferPayload.payer.accountId, nil)
        XCTAssertEqual(transferPayload.payer.accountNumber, nil)
        XCTAssertEqual(transferPayload.payer.phoneNumber, nil)
        
        XCTAssertEqual(transferPayload.additional.first?.fieldid, 1)
        XCTAssertEqual(transferPayload.additional.first?.fieldname, "iFora||4286")
        XCTAssertEqual(transferPayload.additional.first?.fieldvalue, "+7 919 161-96-58")
    }
        
    // MARK: - makeAnywayTransfer
    
    func test_makeAnywayTransfer_shouldThrow_onEmptyParameters() throws {
        
        let sut = makeSUT()
        let payload: [DaDataPhoneData] = [.iFora4285]
        
        XCTAssertThrowsError(
            try sut.makeAnywayTransfer([], payload)
        ) { error in
            XCTAssertEqual(
                error as? MCError,
                .init("Expected ParameterAmount.")
            )
        }
    }
    
    func test_makeAnywayTransfer_shouldThrow_onMissingParameterProduct() throws {
        
        let sut = makeSUT()
        let parameters = makeParameterAmount()
        let payload: [DaDataPhoneData] = [.iFora4285]
        
        XCTAssertThrowsError(
            try sut.makeAnywayTransfer([parameters], payload)
        ) { error in
            XCTAssertEqual(
                error as? MCError,
                .init("Expected ParameterProduct.")
            )
        }
    }
    
    func test_makeAnywayTransfer_shouldThrow_onMissingParameterAmount() throws {
        
        let sut = makeSUT()
        let parameters = makeParameterProduct()
        let payload: [DaDataPhoneData] = [.iFora4285]
        
        XCTAssertThrowsError(
            try sut.makeAnywayTransfer([parameters], payload)
        ) { error in
            XCTAssertEqual(
                error as? MCError,
                .init("Expected ParameterAmount.")
            )
        }
    }
    
    func test_makeAnywayTransfer_shouldThrow_onEmptyPayload() throws {
        
        let sut = makeSUT()
        let amount = makeParameterAmount()
        let product = makeParameterProduct()
        
        XCTAssertThrowsError(
            try sut.makeAnywayTransfer([amount, product], [])
        ) { error in
            XCTAssertEqual(
                error as? MCError,
                .init("Payload expected to be non empty.")
            )
        }
    }
    
    func test_makeAnywayTransfer_shouldThrow_onMissingOperator() throws {
        
        let sut = makeSUT(localAgentDataStub: [:])
        let amount = makeParameterAmount()
        let product = makeParameterProduct()
        let payload: [DaDataPhoneData] = [.iFora4285]

        XCTAssertThrowsError(
            try sut.makeAnywayTransfer([amount, product], payload)
        ) { error in
            XCTAssertEqual(
                error as? MCError,
                .init("Expected to have operator in operator dictionary.")
            )
        }
    }
    
    func test_makeAnywayTransfer_shouldCreateTransferPayload_iFora4285_9rub() throws {
        
        let sut = makeSUT()
        let amount = makeParameterAmount(value: 9.0)
        let product = makeParameterProduct(value: 10000184510)
        let payload: [DaDataPhoneData] = [.iFora4285]
        
        let anywayTransfer = try sut.makeAnywayTransfer([amount, product], payload)
        
        XCTAssertNotNil(anywayTransfer.token)
        XCTAssertEqual(anywayTransfer.endpoint, "/rest/transfer/createAnywayTransfer")
        XCTAssertEqual(anywayTransfer.method, .post)
        
        XCTAssertEqual(anywayTransfer.parameters?.map(\.name), ["isNewPayment"])
        XCTAssertEqual(anywayTransfer.parameters?.map(\.value), ["true"])
        
        let anywayPayload = anywayTransfer.payload
        
        XCTAssertEqual(anywayPayload, .iFora_4285_9rub)
        
        XCTAssertEqual(anywayPayload?.additional, [.a3_NUMBER_1_2_903_9999999])
        XCTAssertEqual(anywayPayload?.amount, 9)
        XCTAssertEqual(anywayPayload?.check, false)
        XCTAssertEqual(anywayPayload?.currencyAmount, "RUB")
        XCTAssertEqual(anywayPayload?.operatorID, "a3_NUMBER_1_2")
        XCTAssertEqual(anywayPayload?.payer, .init(withCardId: 10000184510))
        XCTAssertEqual(anywayPayload?.phoneNumber, "+7 903 999-99-99")
        XCTAssertEqual(anywayPayload?.puref, "iFora||4285")
    }
    
    func test_makeAnywayTransfer_shouldCreateTransferPayload_iFora4285_10rub() throws {
        
        let sut = makeSUT()
        let amount = makeParameterAmount(value: 10.0)
        let product = makeParameterProduct(value: 10000184510)
        let payload: [DaDataPhoneData] = [.iFora4285]
        
        let anywayTransfer = try sut.makeAnywayTransfer([amount, product], payload)
        
        XCTAssertNotNil(anywayTransfer.token)
        XCTAssertEqual(anywayTransfer.endpoint, "/rest/transfer/createAnywayTransfer")
        XCTAssertEqual(anywayTransfer.method, .post)
        
        XCTAssertEqual(anywayTransfer.parameters?.map(\.name), ["isNewPayment"])
        XCTAssertEqual(anywayTransfer.parameters?.map(\.value), ["true"])
        
        let anywayPayload = anywayTransfer.payload
        
        XCTAssertEqual(anywayPayload, .iFora_4285_10rub)
        
        XCTAssertEqual(anywayPayload?.additional, [.a3_NUMBER_1_2_903_9999999])
        XCTAssertEqual(anywayPayload?.amount, 10)
        XCTAssertEqual(anywayPayload?.check, false)
        XCTAssertEqual(anywayPayload?.currencyAmount, "RUB")
        XCTAssertEqual(anywayPayload?.operatorID, "a3_NUMBER_1_2")
        XCTAssertEqual(anywayPayload?.payer, .init(withCardId: 10000184510))
        XCTAssertEqual(anywayPayload?.phoneNumber, "+7 903 999-99-99")
        XCTAssertEqual(anywayPayload?.puref, "iFora||4285")
    }
    
    func test_makeAnywayTransfer_shouldCreateTransferPayload_iFora4286() throws {
        
        let sut = makeSUT()
        let amount = makeParameterAmount(value: 1)
        let product = makeParameterProduct(value: 10000184510)
        let payload: [DaDataPhoneData] = [.iFora4286]

        let anywayTransfer = try sut.makeAnywayTransfer([amount, product], payload)
        
        XCTAssertNotNil(anywayTransfer.token)
        XCTAssertEqual(anywayTransfer.endpoint, "/rest/transfer/createAnywayTransfer")
        XCTAssertEqual(anywayTransfer.method, .post)
        
        XCTAssertEqual(anywayTransfer.parameters?.map(\.name), ["isNewPayment"])
        XCTAssertEqual(anywayTransfer.parameters?.map(\.value), ["true"])
        
        let anywayPayload = anywayTransfer.payload
        
        XCTAssertEqual(anywayPayload, .iFora_4286)

        XCTAssertEqual(anywayPayload?.check, false)
        XCTAssertEqual(anywayPayload?.currencyAmount, "RUB")
        XCTAssertEqual(anywayPayload?.operatorID, "a3_NUMBER_1_2")
        XCTAssertEqual(anywayPayload?.phoneNumber, "+7 919 161-96-58")
        XCTAssertEqual(anywayPayload?.puref, "iFora||4286")
        
        XCTAssertEqual(anywayPayload?.additional, [.a3_NUMBER_1_2_919_1619658])

        XCTAssertEqual(anywayPayload?.payer.accountNumber, nil)
        XCTAssertEqual(anywayPayload?.payer.accountId, nil)
        XCTAssertEqual(anywayPayload?.payer.cardNumber, nil)
        XCTAssertEqual(anywayPayload?.payer.cardId, 10000184510)
        XCTAssertEqual(anywayPayload?.payer.phoneNumber, nil)
    }
    
    // MARK: - Payments Transfer Step 0
    
    func test_processLocalStep0_shouldReturnPayload_9039999999() async throws {
        
        let sut = makeSUT()
        let parameters = try await sut.processLocalStep0(withPhone: "+7 903 999-99-99")
        
        let getPhoneInfo = try ServerCommands.DaDataController.getPhoneInfo(
            token: try XCTUnwrap(sut.token),
            parameters: parameters
        )
        XCTAssertEqual(getPhoneInfo.payload?.phoneNumbersList, ["9039999999"])
        
        let payload = try await sut.execute(command: getPhoneInfo)
        XCTAssertEqual(payload, [.iFora4285])
    }
    
    func test_processLocalStep0_shouldReturnPayload_9191619658() async throws {
        
        let sut = makeSUT()
        let parameters = try await sut.processLocalStep0(withPhone: "+7 919 161-96-58")
        
        let getPhoneInfo = try ServerCommands.DaDataController.getPhoneInfo(
            token: try XCTUnwrap(sut.token),
            parameters: parameters
        )
        XCTAssertEqual(getPhoneInfo.payload?.phoneNumbersList, ["9191619658"])
        
        let payload = try await sut.execute(command: getPhoneInfo)
        XCTAssertEqual(payload, [.iFora4286])
    }
    
    func test_processLocalStep0_shouldFail_onDaData_1234567890() async throws {
        
        let sut = makeSUT()
        let parameters = try await sut.processLocalStep0(withPhone: "+7 123 456-78-90")
        
        do {
            let command = try ServerCommands.DaDataController.getPhoneInfo(
                token: try XCTUnwrap(sut.token),
                parameters: parameters
            )
            XCTAssertEqual(command.payload?.phoneNumbersList, ["1234567890"])
            
            let payload = try await sut.execute(command: command)
            XCTFail("Expected error, got payload instead\n\(payload)")
        } catch {
            typealias GetPhoneInfo = ServerCommands.DaDataController.GetPhoneInfo
            
            let errorMessage = GetPhoneInfo.Response.error.errorMessage
            let serverError = ServerAgentError.serverStatus(
                .error(102),
                errorMessage: errorMessage
            )
            
            XCTAssertEqual(error as NSError, serverError as NSError)
        }
    }
    
    func test_transfer_WIP() async throws {
        
        let sut = makeSUT()
        let parameters = makeStep0Parameters()
        let payload: [DaDataPhoneData] = [.iFora4285]
        
        let anywayTransfer = try sut.makeAnywayTransfer(parameters, payload)
        
        do {
            let res: TransferAnywayResponseData = try await sut.serverAgent.executeCommand(command: anywayTransfer)
            
            XCTAssertEqual(res.amount, 100)
            XCTAssertEqual(res.additionalList.map(\.fieldName), ["INCORRECT", "a3_PERSONAL_ACCOUNT_5_5"])
            XCTAssertEqual(res.additionalList.map(\.fieldValue), ["WRONG NUMBER","1234567890"])
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    // MARK: - paymentsTransferMobileConnectionProcess
    
    func test_paymentsTransferMobileConnectionProcess_shouldFail_onEmptyParameters() async throws {
        
        let sut = makeSUT()

        do {
            let response = try await sut.paymentsTransferMobileConnectionProcess(
                parameters: [],
                process: []
            )
            XCTFail("Expected error, got response instead.\n\(response)")
        } catch let Payments.Error.missingParameter(id) {
            XCTAssertEqual(id, "MobileConnectionPhone")
        } catch {
            XCTFail("Expected \"Payments.Error.missingParameter\" error, got error \(error) instead.")
        }
    }
    
    func test_paymentsTransferMobileConnectionProcess_shouldFailWithAlert_onBadPhoneNumber() async throws {
        
        let sut = makeSUT()
        
        do {
            let parameters = try await sut.processLocalStep0(withPhone: "1234567890")
            let response = try await sut.paymentsTransferMobileConnectionProcess(
                parameters: parameters,
                process: []
            )
            XCTFail("Expected error, got response instead.\n\(response)")
        } catch let Payments.Error.action(.alert(title, message)){
            XCTAssertEqual(title, "Ошибка")
            XCTAssertEqual(message, "На данный момент нет возможности оплатить мобильную связь \"Тинькофф Мобайл\" ООО")
        } catch {
            XCTAssertEqual(error as NSError, NSError(domain: "???", code: 0))
        }
    }
    
    func test_paymentsTransferMobileConnectionProcess_____on9039999999() async throws {
        
        let sut = makeSUT()
        
        do {
            let parameters = try await sut.processLocalStep0(withPhone: "+7 903 999-99-99")
            let response = try await sut.paymentsTransferMobileConnectionProcess(
                parameters: parameters,
                process: []
            )
            XCTFail("Expected error, got response instead.\n\(response)")
        } catch let Payments.Error.action(.alert(title, message)){
            XCTAssertEqual(title, "Ошибка")
            XCTAssertEqual(message, "На данный момент нет возможности оплатить мобильную связь \"Тинькофф Мобайл\" ООО")
        } catch {
            XCTAssertEqual(error as NSError, NSError(domain: "???", code: 0))
        }
    }
    
    func test_paymentsTransferMobileConnectionProcess_____on9191619658() async throws {
        
        let sut = makeSUT()
        
        do {
            let parameters = try await sut.processLocalStep0(withPhone: "+7 919 161-96-58")
            let response = try await sut.paymentsTransferMobileConnectionProcess(
                parameters: parameters,
                process: []
            )
            XCTFail("Expected error, got response instead.\n\(response)")
        } catch let Payments.Error.action(.alert(title, message)){
            XCTAssertEqual(title, "Ошибка")
            XCTAssertEqual(message, "На данный момент нет возможности оплатить мобильную связь \"Тинькофф Мобайл\" ООО")
        } catch {
            XCTAssertEqual(error as NSError, NSError(domain: "???", code: 0))
        }
    }
    
    // MARK: - paymentsProcessRemoteStep
    
    func test_paymentsProcessRemoteStep() async throws {
        
        let sut = makeSUT()
        
        let responseData: TransferAnywayResponseData = makeAnywayResponseData()
        let step = try await sut.paymentsProcessRemoteStep(response: responseData)
        
        XCTAssertNotEqual(step.parameters.map(\.id), [])
        XCTAssertEqual(step.parameters.map(\.id), [])
    }
    
    // MARK: - Helpers Tests
    
    func test_makeParameterProduct() {
        
        let parameterProduct = makeParameterProduct()
        dump(parameterProduct)
        XCTAssertNotNil(parameterProduct)
        XCTAssertNotNil(parameterProduct.productId)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        localAgentDataStub: [String: Data] = [
            "Array<OperatorGroupData>": .operatorGroupData,
        ],
        serverAgentDataStub: [String: DaDataPhoneData] = [
            "9039999999": .iFora4285,
            "9191619658": .iFora4286,
        ],
        essenceStub: ServerAgentStub.EssenceStub = .test,
        _ counts: [ProductType : Int] = [.card: 1],
        currencies: [CurrencyData] = [.rub],
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sessionAgent = ActiveSessionAgentStub()
        let serverAgent = ServerAgentStub(
            stub: serverAgentDataStub,
            essenceStub: essenceStub
        )
        let localAgent = LocalAgentStub(stub: localAgentDataStub)
        
        let sut: Model = .stubbed(
            sessionAgent: sessionAgent,
            serverAgent: serverAgent,
            localAgent: localAgent
        )
        
        sut.products.value = makeProductsData(counts)
        sut.currencyList.value = currencies
        
        // trackForMemoryLeaks(sut, file: file, line: line)
        // trackForMemoryLeaks(sessionAgent, file: file, line: line)
        // trackForMemoryLeaks(serverAgent, file: file, line: line)
        // trackForMemoryLeaks(localAgent, file: file, line: line)
        
        return sut
    }
    
    private func makeStep0Parameters() -> [PaymentsParameterRepresentable] {
        XCTFail("Unimplemented")
        return []
    }
    
    private func makeParameterAmount(
        value: Double = 99.0,
        title: String = "amount",
        currencySymbol: String = "RUB",
        minAmount: Double = 1,
        maxAmount: Double? = nil
    ) -> Payments.ParameterAmount {
        
        .init(
            value: "\(value)",
            title: title,
            currencySymbol: currencySymbol,
            validator: .init(
                minAmount: minAmount,
                maxAmount: maxAmount
            )
        )
    }

    private func makeParameterProduct(
        value: Int = 10000235538,
        title: String = "CARD",
        filter: ProductData.Filter = .generalFrom,
        isEditable: Bool = false
    ) -> Payments.ParameterProduct {
        
        .init(value: "\(value)", title: title, filter: filter, isEditable: isEditable)
    }
    
    private func makeAnywayResponseData(
        amount: Double = 99,
        fee: Double = 0
    ) -> TransferAnywayResponseData {

        .init(
            amount: amount,
            creditAmount: nil,
            currencyAmount: .rub,
            currencyPayee: nil,
            currencyPayer: .rub,
            currencyRate: nil,
            debitAmount: amount,
            fee: fee,
            needMake: true,
            needOTP: true,
            payeeName: nil,
            documentStatus: nil,
            paymentOperationDetailId: 487254,
            additionalList: [
                .init(
                    fieldName: "a3_NUMBER_1_2",
                    fieldTitle: "Номер телефона (без +7)",
                    fieldValue: "9138022858",
                    svgImage: nil,
                    typeIdParameterList: nil,
                    recycle: nil
                ),
                .init(
                    fieldName: "a3_AMOUNT_2_2",
                    fieldTitle: "Сумма, руб.:",
                    fieldValue: "99",
                    svgImage: nil,
                    typeIdParameterList: nil,
                    recycle: nil
                )
            ],
            finalStep: true,
            infoMessage: nil,
            needSum: false,
            printFormType: nil,
            parameterListForNextStep: []
        )
    }
}

// MARK: - DSL

private extension Model {
    
    func makeAnywayTransfer(
        _ parameters: [PaymentsParameterRepresentable],
        _ payload: [DaDataPhoneData]
    ) throws -> ServerCommands.TransferController.CreateAnywayTransfer {
        
        try createAnywayTransfer(
            token: "",
            getPhoneInfoPayload: payload,
            parameters: parameters
        )
    }
    
    func processLocalStep0(
        withPhone phoneNumber: String
    ) async throws -> [PaymentsParameterRepresentable] {
        
        let step0 = try await paymentsProcessLocalStepMobileConnection(
            .init(service: .mobileConnection),
            for: 0
        )
        
        let step = step0.updated(parameter: makePhoneParameter(phoneNumber))
        
        return step.parameters
    }
    
    func paymentsProcessRemoteStep(
        response: TransferResponseData
    ) async throws -> Payments.Operation.Step {
        
        try await paymentsProcessRemoteStep(
            operation: Payments.Operation(service: .mobileConnection),
            response: response
        )
    }
    
    private func makePhoneParameter(_ phoneNumber: String) -> Payments.Parameter{
        let phoneParameterId = Payments.Parameter.Identifier.mobileConnectionPhone.rawValue
        
        return .init(
            id: phoneParameterId,
            value: phoneNumber
        )
    }
    
    func execute<Command: ServerCommand>(
        command: Command
    ) async throws -> Command.Response.Payload {
        
        try await serverAgent.executeCommand(command: command)
    }
}

// MARK: Helpers

private extension ServerAgentStub.EssenceStub {
    
    static let test: Self = .preview
}

private extension TransferAnywayData.Additional {
    
    static let a3_NUMBER_1_2_903_9999999: Self = .init(
        fieldid: 1,
        fieldname: "a3_NUMBER_1_2",
        fieldvalue: "+7 903 999-99-99"
    )
    static let a3_NUMBER_1_2_919_1619658: Self = .init(
        fieldid: 1,
        fieldname: "a3_NUMBER_1_2",
        fieldvalue: "+7 919 161-96-58"
    )
}
#endif
