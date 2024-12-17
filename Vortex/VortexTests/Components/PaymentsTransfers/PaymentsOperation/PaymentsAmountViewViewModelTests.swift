//
//  PaymentsAmountViewViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 16.08.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsAmountViewViewModelTests: XCTestCase {
    
    func test_init_shouldSetTextFieldWithCurrency() {
        
        let sut = makeSUT(currencySymbol: "GBP")
        let spy = ValueSpy(sut.textField.$text)
        
        XCTAssertEqual(spy.values, ["0 GBP"])
    }
    
    func test_init_shouldSetTextFieldWithZero_onBadValue() {
        
        let sut = makeSUT(value: "abc")
        let spy = ValueSpy(sut.textField.$text)
        
        XCTAssertEqual(spy.values, ["0 BTC"])
    }
    
    func test_init_shouldSetTextFieldWithValueAndCurrency() {
        
        let sut = makeSUT(value: "987", currencySymbol: "USD")
        let spy = ValueSpy(sut.textField.$text)
        
        XCTAssertEqual(spy.values, ["987 USD"])
    }
    
    func test_init_shouldSevValueToNilOnNilValue() {
        
        let sut = makeSUT(value: nil)
        let spy = ValueSpy(sut.$value)
        
        XCTAssertEqual(spy.values.map(\.current), [nil])
        XCTAssertEqual(spy.values.map(\.last), [nil])
    }
    
    func test_init_shouldSetValueWithValueAndCurrency() {
        
        let sut = makeSUT(value: "987", currencySymbol: "USD")
        let spy = ValueSpy(sut.$value)
        
        XCTAssertEqual(spy.values.map(\.current), ["987"])
        XCTAssertEqual(spy.values.map(\.last), ["987"])
    }
    
    func test_textFieldValueChange_shouldChangeText() {
        
        let sut = makeSUT()
        let spy = ValueSpy(sut.textField.$text)
        
        sut.setTextField(to: 5, currencySymbol: "GBP")
        sut.setTextField(to: 90, currencySymbol: "USD")
        
        XCTAssertNoDiff(spy.values, [
            "0 BTC",
            "5 GBP",
            "90 USD",
        ])
    }
    
    func test_textFieldValueChange_shouldUpdateValue() {
        
        let sut = makeSUT()
        let spy = ValueSpy(sut.$value)
        
        sut.setTextField(to: 5, currencySymbol: "GBP")
        sut.setTextField(to: 90, currencySymbol: "USD")
        
        XCTAssertNoDiff(spy.values.map(\.current), [
            nil,
            "5.0",
            "90.0",
        ])
        XCTAssertNoDiff(spy.values.map(\.last), [
            nil,
            nil,
            "5.0",
        ])
    }
    
    // MARK: - PaymentsMeToMeViewModel.Mode - general
    
    func test_initWithMode_general_onMissingCurrency() {
        
        let (sut, model) = makeSUT(mode: .general)
        
        XCTAssertEqual(sut.title, "Сумма перевода")
        XCTAssertEqual(sut.transferButton.state, .inactive(title: "Перевести"))
        XCTAssertNoDiff(sut.textField.text, "0 ")
        XCTAssertNoDiff(sut.textField.value, 0)
        XCTAssertNil(model.generalModeCurrency)
    }
    
    func test_initWithMode_general_withCurrencyRUB() {
        
        let (sut, model) = makeSUT(mode: .general)
        model.addCurrency(.rub)
        
        XCTAssertEqual(sut.title, "Сумма перевода")
        XCTAssertEqual(sut.transferButton.state, .inactive(title: "Перевести"))
        XCTAssertNoDiff(sut.textField.text, "0 ")
        XCTAssertNoDiff(sut.textField.value, 0)
        XCTAssertNoDiff(model.generalModeCurrency, "₽")
    }
    
    // MARK: - PaymentsMeToMeViewModel.Mode - demandDeposit
    
    func test_initWithMode_demandDeposit_onMissingCurrency() {
        
        let (sut, model) = makeSUT(mode: .demandDeposit)
        
        XCTAssertEqual(sut.title, "Сумма перевода")
        XCTAssertEqual(sut.transferButton.state, .inactive(title: "Перевести"))
        XCTAssertNoDiff(sut.textField.text, "0 ")
        XCTAssertNoDiff(sut.textField.value, 0)
        XCTAssertNil(model.demandDepositModeCurrency)
    }
    
    func test_initWithMode_demandDeposit_withCurrencyRUB() {
        
        let (sut, model) = makeSUT(mode: .demandDeposit)
        model.addCurrency(.rub)
        
        XCTAssertEqual(sut.title, "Сумма перевода")
        XCTAssertEqual(sut.transferButton.state, .inactive(title: "Перевести"))
        XCTAssertNoDiff(sut.textField.text, "0 ")
        XCTAssertNoDiff(sut.textField.value, 0)
        XCTAssertNoDiff(model.demandDepositModeCurrency, "₽")
    }
    
    // MARK: - PaymentsMeToMeViewModel.Mode - closeAccount
    
    func test_initWithMode_closeAccount() {
        
        let (sut, _) = makeSUT(mode: .closeAccount(ProductData.stub(), 987.6))
        
        XCTAssertEqual(sut.title, "Сумма перевода")
        XCTAssertEqual(sut.transferButton.state, .inactive(title: "Перевести"))
        XCTAssertNoDiff(sut.textField.text, "987,6 ")
        XCTAssertNoDiff(sut.textField.value, 987.6)
    }
    
    // MARK: - PaymentsMeToMeViewModel.Mode - closeDeposit
    
    func test_initWithMode_closeDeposit() {
        
        let (sut, _) = makeSUT(mode: .closeDeposit(ProductData.stub(), 987.6))
        
        XCTAssertEqual(sut.title, "Сумма перевода")
        XCTAssertEqual(sut.transferButton.state, .inactive(title: "Перевести"))
        XCTAssertNoDiff(sut.textField.text, "987,6 ")
        XCTAssertNoDiff(sut.textField.value, 987.6)
    }
    
    // MARK: - PaymentsMeToMeViewModel.Mode - makePaymentTo
    
    func test_initWithMode_makePaymentTo() {
        
        let (sut, _) = makeSUT(mode: .makePaymentTo(ProductData.stub(), 987.6))
        
        XCTAssertEqual(sut.title, "Сумма перевода")
        XCTAssertEqual(sut.transferButton.state, .inactive(title: "Перевести"))
        XCTAssertNoDiff(sut.textField.text, "987,6 ")
        XCTAssertNoDiff(sut.textField.value, 987.6)
    }
    
    // MARK: - PaymentsMeToMeViewModel.Mode - templatePayment
    
    func test_initWithMode_templatePayment_onMissingTemplate() {
        
        let (sut, _) = makeSUT(mode: .templatePayment(123, "This is a template"))
        
        XCTAssertEqual(sut.title, "Сумма перевода")
        XCTAssertEqual(sut.transferButton.state, .inactive(title: "Перевести"))
        XCTAssertNoDiff(sut.textField.text, "0 ")
        XCTAssertNoDiff(sut.textField.value, 0.0)
    }

    func test_initWithMode_templatePayment_onTemplate() {
        
        let templateID = 123
        let accountID = 12345678
        let model: Model = .mockWithEmptyExcept()
        let product: ProductData = .stub(productId: accountID)
        let template: PaymentTemplateData = .templateStub(
            paymentTemplateId: templateID,
            type: .byPhone,
            parameterList: [
                TransferGeneralData(
                    amount: Double(345),
                    check: true,
                    comment: nil,
                    currencyAmount: "345",
                    payer: .test(accountId: accountID),
                    payeeExternal: nil,
                    payeeInternal: TransferGeneralData.PayeeInternal(
                        accountId: accountID, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil, productCustomName: nil
                    )
                )
            ]
        )
        model.addTemplate(template)
        model.products.value[.card] = [product]
        let (sut, _) = makeSUT(
            mode: .templatePayment(templateID, "This is a template"),
            model: model
        )
        
        XCTAssertEqual(sut.title, "Сумма перевода")
        XCTAssertEqual(sut.transferButton.state, .inactive(title: "Перевести"))
        XCTAssertNoDiff(sut.textField.text, "345 ")
        XCTAssertNoDiff(sut.textField.value, 345.0)
    }
    
    // MARK: - PaymentsMeToMeViewModel.Mode - makePaymentToDeposite
    
    func test_initWithMode_makePaymentToDeposite() {
        
        let (sut, _) = makeSUT(mode: .makePaymentToDeposite(ProductData.stub(), 987.6))
        
        XCTAssertEqual(sut.title, "Сумма перевода")
        XCTAssertEqual(sut.transferButton.state, .inactive(title: "Перевести"))
        XCTAssertNoDiff(sut.textField.text, "987,6 ")
        XCTAssertNoDiff(sut.textField.value, 987.6)
    }
    
    // MARK: - PaymentsMeToMeViewModel.Mode - transferAndCloseDeposit
    
    func test_initWithMode_transferAndCloseDeposit() {
        
        let (sut, _) = makeSUT(mode: .transferAndCloseDeposit(ProductData.stub(), 987.6))
        
        XCTAssertEqual(sut.title, "Сумма перевода")
        XCTAssertEqual(sut.transferButton.state, .inactive(title: "Перевести"))
        XCTAssertNoDiff(sut.textField.text, "987,6 ")
        XCTAssertNoDiff(sut.textField.value, 987.6)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        value: Payments.Parameter.Value = nil,
        currencySymbol: String = "BTC",
        file: StaticString = #file,
        line: UInt = #line
    ) -> PaymentsAmountView.ViewModel {
        
        let parameterAmount = parameterAmount(
            value: value,
            currencySymbol: currencySymbol
        )
        let model: Model = .mockWithEmptyExcept()
        let sut = PaymentsAmountView.ViewModel(
            with: parameterAmount,
            model: model
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return sut
    }
    
    private func parameterAmount(
        value: Payments.Parameter.Value,
        currencySymbol: String
    ) -> Payments.ParameterAmount {
        
        .init(
            value: value,
            title: "Amount",
            currencySymbol: currencySymbol,
            validator: .init(minAmount: 1, maxAmount: nil)
        )
    }
    
    private func makeSUT(
        mode: PaymentsMeToMeViewModel.Mode,
        model: Model? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: PaymentsAmountView.ViewModel,
        model: Model
    ) {
        let model: Model = model ?? .mockWithEmptyExcept()
        let sut = PaymentsAmountView.ViewModel(
            mode: mode,
            model: model
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
}

// MARK: - DSL

private extension PaymentsAmountView.ViewModel {
    
    func setTextField(
        to value: Double,
        currencySymbol: String
    ) {
        textField.update(value, currencySymbol: currencySymbol)
        XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
}

private extension PaymentsAmountView.ViewModel.TransferButtonViewModel {
    
    var state: State {
        switch self {
        case let .inactive(title: title):
            return .inactive(title: title)
            
        case let .active(title: title, _):
            return .active(title: title)
            
        case let .loading(_, iconSize: iconSize):
            return .loading(iconSize: iconSize)
        }
    }
    
    enum State: Equatable {
        
        case inactive(title: String)
        case active(title: String)
        case loading(iconSize: CGSize)
    }
}

private extension Model {
    
    var generalModeCurrency: String? {
        
        dictionaryCurrencySymbol(for: Currency.rub.description)
    }
    
    var demandDepositModeCurrency: String? {
        
        dictionaryCurrencySymbol(for: Currency.rub.description)
    }
    
    func addTemplate(_ template: PaymentTemplateData) {
        
        paymentTemplates.value.append(template)
    }
}
