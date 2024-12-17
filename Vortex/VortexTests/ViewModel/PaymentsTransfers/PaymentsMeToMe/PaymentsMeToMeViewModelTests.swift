//
//  PaymentsMeToMeViewModelTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 21.06.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsMeToMeViewModelTests: XCTestCase {
    
    let templateId = 1
    let oldName = "oldName"
    
    func test_paymentMeToMe_bindRename_shouldSetTitle() throws {
        
        let model = modelWithNecessaryData()
        let newName = "newName"
        
        let name = model.paymentTemplates.value.first(where: { $0.id == templateId })?.name
        
        let sut = makeSUT(
            model: model,
            mode: .templatePayment(templateId, name ?? "Между своими")
        )
        
        let renameViewModel = TemplatesListViewModel.RenameTemplateItemViewModel(
            oldName: oldName, templateID: templateId)
        sut?.bindRename(rename: renameViewModel)
        
        renameViewModel.action.send(TemplatesListViewModelAction.RenameSheetAction.SaveNewName(
            newName: newName,
            itemId: 1
        ))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertEqual(sut?.title, newName)
        XCTAssertNil(sut?.bottomSheet)
    }
    
    func test_paymentMeToMe_renameBottomSheet_shouldSetBottomSheet() throws {
        
        let model = modelWithNecessaryData()
        
        let name = model.paymentTemplates.value.first(where: { $0.id == templateId })?.name
        
        let sut = makeSUT(
            model: model,
            mode: .templatePayment(templateId, name ?? "Между своими")
        )
        
        let title = try XCTUnwrap(sut?.title)
        
        sut?.renameBottomSheet(
            oldName: title,
            templateId: templateId
        )
        
        XCTAssertNotNil(sut?.bottomSheet)
    }
    
    // MARK: - test updatePaymentInfo
    
    func test_updatePaymentInfo_rubToRub_shouldCallSetDefaultInfoButton() {
        
        var setDefaultInfoButtonCalls = 0
            
        updatePaymentInfo(
            currencyFrom: .rub,
            currencyTo: .rub,
            setDefaultInfoButton: { setDefaultInfoButtonCalls += 1 }
        )
        
        XCTAssertNoDiff(setDefaultInfoButtonCalls, 1)
    }
        
    func test_updatePaymentInfo_rubToNotRub_rateNil_shouldCallSetDefaultInfoButton() {
        
        var setDefaultInfoButtonCalls = 0
        
        updatePaymentInfo(
            currencyFrom: .rub,
            currencyTo: .usd,
            rateTo: nil,
            rateFrom: nil,
            setDefaultInfoButton: { setDefaultInfoButtonCalls += 1 }
        )
        
        XCTAssertNoDiff(setDefaultInfoButtonCalls, 1)
    }
    
    func test_updatePaymentInfo_notRubToRub_rateNil_shouldCallSetDefaultInfoButton() {
        
        var setDefaultInfoButtonCalls = 0
        
        updatePaymentInfo(
            currencyFrom: .eur,
            currencyTo: .rub,
            rateTo: nil,
            rateFrom: nil,
            setDefaultInfoButton: { setDefaultInfoButtonCalls += 1 }
        )

        XCTAssertNoDiff(setDefaultInfoButtonCalls, 1)
    }
    
    func test_updatePaymentInfo_rubToNotRub_rateToNotNil_amount0_shouldCallSetText() {
        
        var text = ""

        updatePaymentInfo(
            currencyFrom: .rub,
            currencyTo: .eur,
            rateTo: .defaultValueEur,
            amount: 0,
            setText: { text = $0 }
        )
        
        XCTAssertNoDiff(text, "1 currencySymbolTo  -  87,30 currencySymbolFrom")
    }
    
    func test_updatePaymentInfo_rubToNotRub_rateToNotNil_amountMore0_shouldCallSetText() {
        
        var text = ""
        
        updatePaymentInfo(
            currencyFrom: .rub,
            currencyTo: .eur,
            rateTo: .defaultValueEur,
            amount: 10,
            setText: { text = $0 }
        )

        XCTAssertNoDiff(text, "0,11 currencySymbolTo   |   1 currencySymbolTo  -  87,30 currencySymbolFrom")
    }
    
    func test_updatePaymentInfo_notRubToRub_rateFromNotNil_amount0_shouldCallSetText() {
        
        var text = ""
        
        updatePaymentInfo(
            currencyFrom: .eur,
            currencyTo: .rub,
            amount: 0,
            rateFrom: .defaultValueEur,
            setText: { text = $0 }
        )
        
        XCTAssertNoDiff(text, "1 currencySymbolFrom  -  85,90 currencySymbolTo")
    }
    
    func test_updatePaymentInfo_notRubToRub_rateFromNotNil_amountMore0_shouldCallSetText() {
        
        var text = ""
        
        updatePaymentInfo(
            currencyFrom: .eur,
            currencyTo: .rub,
            amount: 10,
            rateFrom: .defaultValueEur,
            setText: { text = $0 }
        )

        XCTAssertNoDiff(text, "859,00 currencySymbolTo   |   1 currencySymbolFrom  -  85,90 currencySymbolTo")
    }
    
    func test_updatePaymentInfo_notRubToNotRub_rateNotNil_amount0_shouldCallSetText() {
        
        var text = ""
        
        updatePaymentInfo(
            currencyFrom: .eur,
            currencyTo: .usd,
            rateTo: .defaultValueEur,
            amount: 0,
            rateFrom: .defaultValueUsd,
            setText: { text = $0 }
        )

        XCTAssertNoDiff(text, "1 currencySymbolTo  -  1,06 currencySymbolFrom")
    }
    
    func test_updatePaymentInfo_notRubToNotRub_rateNotNil_amountMore0_shouldCallSetText() {
        
        var text = ""
        
        updatePaymentInfo(
            currencyFrom: .eur,
            currencyTo: .usd,
            rateTo: .defaultValueEur,
            amount: 10,
            rateFrom: .defaultValueUsd,
            setText: { text = $0 }
        )
        
        XCTAssertNoDiff(text, "9,42 currencySymbolTo   |   1 currencySymbolTo  -  1,06 currencySymbolFrom")
    }
    
    // MARK: - createAlertData / makeAlert Tests
    
    func test_createAlertData_withEmptyDataError_shouldReturnCorrectData() {
        
        let sut = makeSUT(model: modelWithNecessaryData(), mode: .general)
        let error = ModelError.emptyData(message: "Test error message")
        
        let alertData = sut?.createAlertData(error)
        
        XCTAssertEqual(alertData?.title, "Ошибка")
        XCTAssertEqual(alertData?.messageError, "Test error message")
    }
    
    func test_createAlertData_withStatusError_shouldReturnCorrectData() {
        
        let sut = makeSUT(model: modelWithNecessaryData(), mode: .general)
        let error = ModelError.statusError(status: .error(123), message: "Test status error")
        
        let alertData = sut?.createAlertData(error)
        
        XCTAssertEqual(alertData?.title, "Ошибка")
        XCTAssertEqual(alertData?.messageError, "Test status error")
    }
    
    func test_createAlertData_withServerCommandError_shouldReturnCorrectData() {
        
        let sut = makeSUT(model: modelWithNecessaryData(), mode: .general)
        let error = ModelError.serverCommandError(error: "Test server error")
        
        let alertData = sut?.createAlertData(error)
        
        XCTAssertEqual(alertData?.title, "Ошибка")
        XCTAssertEqual(alertData?.messageError, "Test server error")
    }

    func test_createAlertData_withUnauthorizedCommandAttempt_shouldReturnNil() {
        
        let sut = makeSUT(model: modelWithNecessaryData(), mode: .general)
        let error = ModelError.unauthorizedCommandAttempt
        
        let alertData = sut?.createAlertData(error)
        
        XCTAssertNil(alertData)
    }
    
    func test_createAlertData_withMeToMeCreateTransferAndSpecificError_shouldReturnSpecialData() {
        
        let sut = makeSUT(model: modelWithNecessaryData(), mode: .general)
        let error = ModelError.serverCommandError(error: "Превышен лимит времени на запрос.")
        
        let alertData = sut?.createAlertData(error, isFromMeToMeCreateTransfer: true)
        
        XCTAssertEqual(alertData?.title, "Операция в обработке")
        XCTAssertEqual(alertData?.messageError, "Проверьте её статус позже в истории операций.")
    }

    func test_createAlertData_withMeToMeCreateTransferAndOtherError_shouldReturnNormalData() {
        
        let sut = makeSUT(model: modelWithNecessaryData(), mode: .general)
        let error = ModelError.serverCommandError(error: "Some other error")
        
        let alertData = sut?.createAlertData(error)
        
        XCTAssertEqual(alertData?.title, "Ошибка")
        XCTAssertEqual(alertData?.messageError, "Some other error")
    }
    
    func test_createAlertData_withoutMeToMeCreateTransferAndSpecificError_shouldReturnNormalData() {
        
        let sut = makeSUT(model: modelWithNecessaryData(), mode: .general)
        let error = ModelError.serverCommandError(error: "Превышен лимит времени на запрос.")
        
        let alertData = sut?.createAlertData(error)
        
        XCTAssertEqual(alertData?.title, "Ошибка")
        XCTAssertEqual(alertData?.messageError, "Превышен лимит времени на запрос.")
    }
    
    func test_createTransferFailure_shouldSetProcessingAlert() {
        
        let failureResponse = ModelAction.Payment.MeToMe.CreateTransfer.Response(result: .failure(.statusError(status: .timeout, message: "Превышен лимит времени на запрос.")))
        let sut = makeSUTWithAction(failureResponse: failureResponse)
        
        XCTAssertEqual(sut?.alert?.title, "Операция в обработке")
        XCTAssertEqual(sut?.alert?.message, "Проверьте её статус позже в истории операций.")
    }

    func test_createTransferFailure_shouldSetErrorAlert() {
        
        let failureResponse = ModelAction.Payment.MeToMe.CreateTransfer.Response(result: .failure(.statusError(status: .serverError, message: "Все плохо")))
        let sut = makeSUTWithAction(failureResponse: failureResponse)
        
        XCTAssertEqual(sut?.alert?.title, "Ошибка")
        XCTAssertEqual(sut?.alert?.message, "Все плохо")
    }

    func test_createTransferFailure_shouldSetNilAlert() {
        
        let failureResponse = ModelAction.Payment.MeToMe.CreateTransfer.Response(result: .failure(.statusError(status: .serverError, message: nil)))
        let sut = makeSUTWithAction(failureResponse: failureResponse)
        
        XCTAssertNil(sut?.alert?.title)
        XCTAssertNil(sut?.alert?.message)
    }

    func test_createTransferFailure_shouldSetServerCommandErrorAlert() {
        
        let failureResponse = ModelAction.Payment.MeToMe.CreateTransfer.Response(result: .failure(.serverCommandError(error: "serverCommandError")))
        let sut = makeSUTWithAction(failureResponse: failureResponse)
        
        XCTAssertEqual(sut?.alert?.title, "Ошибка")
        XCTAssertEqual(sut?.alert?.message, "serverCommandError")
    }
    
    // MARK: - PaymentsMeToMeViewModel Helpers Tests

    func test_getTemplateId_withPaymentMeToMeModeTemplatePayment() throws {
    
        let sut = makeSUT(
            model: modelWithNecessaryData(),
            mode: .templatePayment(1, "name")
        )
        
        XCTAssertNoDiff(sut?.getTemplateId(), 1)
    }
    
    func test_getTemplateId_withPaymentMeToMeModeDemandDeposit() throws {
    
        let sut = makeSUT(
            model: modelWithNecessaryData(),
            mode: .demandDeposit
        )
        
        XCTAssertNoDiff(sut?.getTemplateId(), nil)
    }
    
    // MARK: MeToMePayment Tests
    
    func test_meToMePayment_init_withModeMeToMe_shouldReturnMeToMePayment() throws {
    
        let sut = MeToMePayment(
            mode: .meToMe(
                templateId: 1,
                from: 1,
                to: 1,
                .makeDummy(amount: 1)
            )
        )
        
        XCTAssertNoDiff(sut, .init(
            templateId: 1,
            payerProductId: 1,
            payeeProductId: 1,
            amount: 1
        ))
    }
    
    func test_meToMePayment_init_withModeMeToMe_shouldReturnNil() throws {
    
        let sut = MeToMePayment(
            mode: .normal
        )
        
        XCTAssertNoDiff(sut, nil)
    }
    
    func test_meToMePayment_withSendActionMakeTransferActionSuccess_shouldSpyValue1() throws {
        
        let model = makeModelWithServerAgentStub()
        let sut = PaymentsMeToMeViewModel(model, mode: .general)
        let spy = ValueSpy(model.action.compactMap { $0 as? ModelAction.Payment.MeToMe.MakeTransfer.Response })

        XCTAssertNotNil(sut)
        XCTAssertNoDiff(
            try spy.values.first?.result.get().documentStatus,
            nil
        )

        model.action.send(ModelAction.Payment.MeToMe.MakeTransfer.Request(transferResponse: .makeDummy())
        )
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.5)

        XCTAssertNoDiff(
            try spy.values.first?.result.get().documentStatus,
            .complete
        )
    }
    
    // MARK: - handle Create Transfer Response
 
    func test_handleCreateTransferResponse_success_needMake() {
        
        let transferResponse = TransferResponseData.makeDummy(needMake: true, needOTP: false)
        let response = ModelAction.Payment.MeToMe.CreateTransfer.Response(result: .success(.makeDummy(needMake: true, needOTP: false)))
        
        let model = modelWithNecessaryData()
        let sut = makeSUT(model: model, mode: .general)!
        
        let spy = ValueSpy(model.action.compactMap { $0 as? ModelAction.Payment.MeToMe.MakeTransfer.Request })
        
        sut.handleCreateTransferResponse(response)
        
        XCTAssertEqual(sut.state, .loading)
        XCTAssertEqual(spy.values.first?.transferResponse, transferResponse)
    }
    
    func test_handleCreateTransferResponse_success_noNeedMake_noNeedOTP() {
        
        let response = ModelAction.Payment.MeToMe.CreateTransfer.Response(
            result: .success(.makeDummy(needMake: false, needOTP: false))
        )
        
        let (sut, _, spy) = makeSUTWithSpy(model: modelWithNecessaryData(), response: response)
        
        XCTAssertEqual(sut.state, .normal)
        XCTAssertEqual(spy.values.count, 0)
    }
    
    func test_handleCreateTransferResponse_success_noNeedMake_needOTP() {
        
        let response = ModelAction.Payment.MeToMe.CreateTransfer.Response(
            result: .success(.makeDummy(needMake: false, needOTP: true))
        )
        
        let (sut, _, _) = makeSUTWithSpy(model: modelWithNecessaryData(), response: response)
        let spy = ValueSpy(sut.action.compactMap { $0 as? PaymentsMeToMeAction.Response.Failed })
        
        XCTAssertEqual(spy.values.count, 0)
    }
    
    func test_handleCreateTransferResponse_failure_timeout() {
        
        let response = ModelAction.Payment.MeToMe.CreateTransfer.Response(
            result: .failure(.statusError(status: .timeout, message: "Timeout error"))
        )
        
        let (sut, _, _) = makeSUTWithSpy(model: modelWithNecessaryData(), response: response)
        
        XCTAssertEqual(sut.state, .normal)
        XCTAssertEqual(sut.alert?.title, "Операция в обработке")
        XCTAssertEqual(sut.alert?.message, "Проверьте её статус позже в истории операций.")
    }
    
    func test_handleCreateTransferResponse_failure_other() {
        
        let response = ModelAction.Payment.MeToMe.CreateTransfer.Response(
            result: .failure(.statusError(status: .serverError, message: "Server error"))
        )
        
        let (sut, _, _) = makeSUTWithSpy(model: modelWithNecessaryData(), response: response)
        
        XCTAssertEqual(sut.state, .normal)
        XCTAssertEqual(sut.alert?.title, "Ошибка")
        XCTAssertEqual(sut.alert?.message, "Server error")
    }
    
    func test_handleCreateTransferResponse_success_noNeedMake_noNeedOTP_success() {
        
        let response = ModelAction.Payment.MeToMe.CreateTransfer.Response(
            result: .success(.makeDummy(needMake: false, needOTP: false, documentStatus: .complete))
        )
        
        let (sut, _, spy) = makeSUTWithSpy(model: modelWithNecessaryData(), response: response)
        
        XCTAssertEqual(sut.state, .normal)
        XCTAssertEqual(spy.values.count, 1)
        XCTAssertNotNil(spy.values.first?.viewModel)
    }
    
    func test_handleMakeTransferResponse_success() {
        
        let response = ModelAction.Payment.MeToMe.MakeTransfer.Response(
            result: .success(.makeDummy(documentStatus: .complete))
        )
        
        let (sut, _, spy) = makeSUTWithSpyForMakeTransfer(model: modelWithNecessaryData(), response: response)
        
        XCTAssertEqual(sut.state, .normal)
        XCTAssertEqual(spy.values.count, 1)
        XCTAssertNotNil(spy.values.first?.viewModel)
    }
    
    func test_handleMakeTransferResponse_failure_timeout() {
        
        let response = ModelAction.Payment.MeToMe.MakeTransfer.Response(
            result: .failure(.statusError(status: .timeout, message: "Timeout error"))
        )
        
        let (sut, _, _) = makeSUTWithSpyForMakeTransfer(model: modelWithNecessaryData(), response: response)
        
        XCTAssertEqual(sut.state, .normal)
        XCTAssertEqual(sut.alert?.title, "Операция в обработке")
        XCTAssertEqual(sut.alert?.message, "Проверьте её статус позже в истории операций.")
    }
    
    func test_handleMakeTransferResponse_failure_other() {
        
        let response = ModelAction.Payment.MeToMe.MakeTransfer.Response(
            result: .failure(.statusError(status: .serverError, message: "Server error"))
        )
        
        let (sut, _, _) = makeSUTWithSpyForMakeTransfer(model: modelWithNecessaryData(), response: response)
        
        XCTAssertEqual(sut.state, .normal)
        XCTAssertEqual(sut.alert?.title, "Ошибка")
        XCTAssertEqual(sut.alert?.message, "Server error")
    }
    
    func test_handleMakeTransferResponse_success_emptySwapViewModelItems() {
        
        let model = modelWithNecessaryData()
        let response = ModelAction.Payment.MeToMe.MakeTransfer.Response(
            result: .success(.makeDummy(documentStatus: .complete))
        )
        
        let (sut, _, spy) = makeSUTWithSpyForMakeTransfer(model: model, response: response)
        sut.swapViewModel.items = []
        
        XCTAssertEqual(sut.state, .normal)
        XCTAssertEqual(spy.values.count, 1)
    }
    
    func test_handleMakeTransferResponse_success_inProgressDocumentStatus() {
        
        let response = ModelAction.Payment.MeToMe.MakeTransfer.Response(
            result: .success(.makeDummy(documentStatus: .inProgress))
        )
        
        let (sut, _, spy) = makeSUTWithSpyForMakeTransfer(model: modelWithNecessaryData(), response: response)
        
        XCTAssertEqual(sut.state, .normal)
        XCTAssertEqual(spy.values.count, 1)
    }
    
    func test_handleMakeTransferResponse_failure_other_error() {
        
        let sut = makeSUT(model: modelWithNecessaryData(), mode: .general)
        let failureResponse = ModelAction.Payment.MeToMe.MakeTransfer.Response(
            result: .failure(.emptyData(message: "Empty data error"))
        )
        
        sut?.handleMakeTransferResponse(failureResponse)
        
        XCTAssertEqual(sut?.state, .normal)
        XCTAssertEqual(sut?.alert?.title, "Ошибка")
        XCTAssertEqual(sut?.alert?.message, "Empty data error")
    }
    
    func test_handleMakeTransferResponse_success_withOutDocumentStatus_guardElseReturn() {
        
        let model = modelWithNecessaryData()
        let sut = makeSUT(model: model, mode: .general)
        let successResponse = ModelAction.Payment.MeToMe.MakeTransfer.Response(
            result: .success(.makeDummy())
        )
        
        let spy = ValueSpy(sut!.action.compactMap { $0 as? PaymentsMeToMeAction.Response.Success })
        
        sut?.handleMakeTransferResponse(successResponse)
        
        XCTAssertEqual(spy.values.count, 0)
    }
    
    // MARK: - Helpers
    
    private func makeModelWithServerAgentStub() -> Model {
    
        let sessionAgent = ActiveSessionAgentStub()
        let serverAgent = ServerAgentTestStub(makeTransferStub())
        
        let model: Model = .mockWithEmptyExcept(
            sessionAgent: sessionAgent,
            serverAgent: serverAgent
        )
        
        model.products.value = [.card: [.stub(productType: .card)], .account: [.stub()]]
        
        return model
    }
    
    private func makeTransferStub() -> [ServerAgentTestStub.Stub] {
        
        [
            .makeTransfer(.success(.init(
                statusCode: .ok,
                errorMessage: nil,
                data: .init(
                    documentStatus: .complete,
                    paymentOperationDetailId: 1
                )
            )))
        ]
    }
    
    private func updatePaymentInfo(
        currencyFrom: Currency = .rub,
        currencyTo: Currency = .rub,
        rateTo: ExchangeRateData? = nil,
        amount: Double = 0,
        rateFrom: ExchangeRateData? = nil,
        setDefaultInfoButton: @escaping () -> Void = { },
        setText: @escaping (String) -> Void = { _ in }
    ) {
        PaymentsMeToMeViewModel.updatePaymentInfo(
            currencyFrom: currencyFrom,
            currencyTo: currencyTo,
            rateDataTo: rateTo,
            currencySymbolFrom: "currencySymbolFrom",
            currencySymbolTo: "currencySymbolTo",
            amount: amount,
            rateDataFrom: rateFrom,
            setDefaultInfoButton: setDefaultInfoButton,
            setText: setText
        )
    }
}

extension PaymentsMeToMeViewModelTests {
    
    func modelWithNecessaryData() -> Model {
        
        let model = Model.mockWithEmptyExcept()
        model.paymentTemplates.value.append(.templateStub(
            paymentTemplateId: templateId,
            type: .betweenTheir,
            parameterList: TransferGeneralData.generalStub())
        )
        
        model.products.value = [.card: [ProductData.stub(productId: 1)]]
        
        return model
    }
    
    func makeSUTWithSpy(
        model: Model,
        mode: PaymentsMeToMeViewModel.Mode = .general,
        response: ModelAction.Payment.MeToMe.CreateTransfer.Response,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: PaymentsMeToMeViewModel,
        model: Model,
        spy: ValueSpy<PaymentsMeToMeAction.Response.Success>
    ) {
        let sut = makeSUT(model: model, mode: mode, file: file, line: line)!
        let spy = ValueSpy(sut.action.compactMap { $0 as? PaymentsMeToMeAction.Response.Success })
        
        sut.handleCreateTransferResponse(response)
        
        return (sut, model, spy)
    }
    
    func makeSUTWithSpyForMakeTransfer(
        model: Model,
        mode: PaymentsMeToMeViewModel.Mode = .general,
        response: ModelAction.Payment.MeToMe.MakeTransfer.Response,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: PaymentsMeToMeViewModel,
        model: Model,
        spy: ValueSpy<PaymentsMeToMeAction.Response.Success>
    ) {
        let sut = makeSUT(model: model, mode: mode, file: file, line: line)!
        let spy = ValueSpy(sut.action.compactMap { $0 as? PaymentsMeToMeAction.Response.Success })
        sut.handleMakeTransferResponse(response)
        
        return (sut, model, spy)
    }
    
    func makeSUT(
        model: Model,
        mode: PaymentsMeToMeViewModel.Mode,
        file: StaticString = #file,
        line: UInt = #line
    ) -> PaymentsMeToMeViewModel? {
        
        let sut = PaymentsMeToMeViewModel(
            model,
            mode: mode
        )
        
        if let sut {
            
            trackForMemoryLeaks(sut, file: file, line: line)
        }
        
        return sut
    }
    
    func makeSUTWithAction(
        mode: PaymentsMeToMeViewModel.Mode = .general,
        failureResponse: ModelAction.Payment.MeToMe.CreateTransfer.Response,
        file: StaticString = #file,
        line: UInt = #line
    ) -> PaymentsMeToMeViewModel? {
        
        let model = makeModelWithServerAgentStub()
        let sut = PaymentsMeToMeViewModel(model, mode: mode)
        
        if let sut {
            trackForMemoryLeaks(sut, file: file, line: line)
        }
        
        _ = ValueSpy(model.action.compactMap { $0 as? ModelAction.Payment.MeToMe.CreateTransfer.Response })
        
        model.action.send(failureResponse)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        return sut
    }
}

extension ProductData {
    
    //TODO: remove stub after merge DBSNEW-8883
    static func stub(
        productId: Int = UUID().hashValue,
        currency: String = "RUB",
        balance: Double? = nil,
        balanceRub: Double? = nil
    ) -> ProductData {
        
        return .init(
            id: productId,
            productType: .card,
            number: "1",
            numberMasked: nil,
            accountNumber: nil,
            balance: balance,
            balanceRub: balanceRub,
            currency: currency,
            mainField: "",
            additionalField: nil,
            customName: nil,
            productName: "productName",
            openDate: nil,
            ownerId: 1,
            branchId: nil,
            allowCredit: true,
            allowDebit: true,
            extraLargeDesign: SVGImageData.test,
            largeDesign: SVGImageData.test,
            mediumDesign: SVGImageData.test,
            smallDesign: SVGImageData.test,
            fontDesignColor: .init(description: ""),
            background: [.init(description: "")],
            order: 1,
            isVisible: true,
            smallDesignMd5hash: "1",
            smallBackgroundDesignHash: ""
        )
    }
}

private extension Date {
    
    static let defaultDate = Date.dateUTC(with: 1648512000000)
}

private extension ExchangeRateData {
    
    static let defaultValueEur = ExchangeRateData.init(
        currency: .eur,
        currencyCode: "978",
        currencyId: 90001299,
        currencyName: "Евро",
        rateBuy: 85.9,
        rateBuyDate: .defaultDate,
        rateSell: 87.3,
        rateSellDate: .defaultDate,
        rateType: "КурсДБОФЛ",
        rateTypeId: 10000000002
    )
    
    static let defaultValueUsd = ExchangeRateData.init(
        currency: .usd,
        currencyCode: "978",
        currencyId: 90001299,
        currencyName: "$",
        rateBuy: 80.9,
        rateBuyDate: .defaultDate,
        rateSell: 81.3,
        rateSellDate: .defaultDate,
        rateType: "КурсДБОФЛ",
        rateTypeId: 10000000002
    )
}
