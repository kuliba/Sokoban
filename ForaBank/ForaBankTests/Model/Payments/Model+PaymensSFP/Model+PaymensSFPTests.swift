//
//  Model+PaymensSFPTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.09.2023.
//

@testable import ForaBank
import XCTest

final class Model_PaymensSFPTests: XCTestCase {
    
    func test_shouldReturnGivenProductIDForNilSource() {
        
        let source: Payments.Operation.Source? = nil
        let productID = "abc"
        let sut = makeSUT()
        
        let result = sut.productWithSource(
            source: source,
            productId: productID
        )
        
        XCTAssertNoDiff(result, productID)
    }
    
    func test_shouldReturnGivenProductIDForNonTemplateSource() {
        
        let sources: [Payments.Operation.Source] = [
            .avtodor,
            .c2b(anyURL()),
            .c2bSubscribe(anyURL()),
            .gibdd,
            .latestPayment(1),
            .qr,
            .sfp(phone: "123", bankId: .contact),
        ]
        
        sources.forEach { source in
            
            let productID = "abc"
            let sut = makeSUT()
            
            let result = sut.productWithSource(
                source: source,
                productId: productID
            )
            
            XCTAssertNoDiff(result, productID)
        }
    }
    
    func test_shouldReturnNilOnMissingTemplate() {
        
        let templateID = 123
        let source: Payments.Operation.Source? = .template(templateID)
        let productID = "abc"
        let sut = makeSUT()
        
        let result = sut.productWithSource(
            source: source,
            productId: productID
        )
        
        XCTAssertNil(result)
        XCTAssertFalse(sut.hasTemplate(withID: templateID))
    }
    
    func test_shouldReturnProductIDForTemplate() {
        
        let templateID = 123
        let payerAccountID = 4567
        let source: Payments.Operation.Source? = .template(templateID)
        let productID = "abc"
        let sut = makeSUT()
        sut.paymentTemplates.value = [makeTemplate(
            templateID: templateID,
            payerAccountID: payerAccountID
        )]
        
        let result = sut.productWithSource(
            source: source,
            productId: productID
        )
        
        XCTAssertNoDiff(result, "\(payerAccountID)")
        XCTAssertTrue(sut.hasTemplate(withID: templateID))
    }
    
    func test_bankParameter_sourceSFP_shouldReturnParameter() {
        
        let sut = makeSUT()
        let operation = Payments.Operation(
            service: .sfp,
            source: .sfp(phone: "phone", bankId: "1")
        )
        
        let bankParameter = sut.createBankParameter(
            latestPaymentBankIds: nil,
            operation,
            operationPhone: nil,
            banksIds: []
        )
        
        XCTAssertNoDiff(bankParameter.parameter.id, Self.bankParameterTest.id)
    }
    
    func test_bankParameter_sourceLatestPayment_shouldReturnParameter() {
        
        let sut = makeSUT()
        sut.bankList.value = [.dummy(id: "1", bankType: .sfp, bankCountry: "RU")]
        sut.latestPayments.value = [PaymentGeneralData(
            id: 1,
            amount: nil,
            bankId: "",
            bankName: nil,
            date: Date(),
            paymentDate: "",
            phoneNumber: "",
            type: .phone
        )]
        
        let operation = Payments.Operation(
            service: .sfp,
            source: .latestPayment(1)
        )
        
        let bankParameter = sut.createBankParameter(
            latestPaymentBankIds: nil,
            operation,
            operationPhone: nil,
            banksIds: []
        )
        
        XCTAssertNoDiff(bankParameter.parameter.id, Self.bankParameterTest.id)
    }
    
    func test_getHeaderIconForOperation_sfpForaBank_returnsNil() {
        
        XCTAssertNil(PPIcon.init(source: makeSPFSource()))
    }
    
    func test_getHeaderIconForOperation_sfpNonForaBank_returnsSbpIcon() {
        
        XCTAssertEqual(PPIcon.init(source: makeSPFSource(bankID: "123123123"))?.equatable, .testSBPIcon)
    }
    
    func test_getHeaderIconForOperation_otherSource_returnsSbpIcon() {
        
        XCTAssertEqual(PPIcon.init(source: Payments.Operation.Source.avtodor)?.equatable, .testSBPIcon)
    }
    
    func test_getHeaderIconForOperation_nilSource_returnsSbpIcon() {
        
        XCTAssertEqual(PPIcon.init(source: nil)?.equatable, .testSBPIcon)
    }
    
    func test_getHeaderIconForParameters_emptyParameters_returnsNil() {
        
        XCTAssertNil(PPIcon.init(parameters: [])?.equatable)
    }
    
    func test_getHeaderIconForParameters_sfpBankNotFora_returnsSbpIcon() {
        
        XCTAssertEqual(PPIcon(parameters: makeParameter())?.equatable, .testSBPIcon)
    }
    
    func test_getHeaderIconForParameters_sfpBankIsFora_returnsNil() {
        
        XCTAssertNil(PPIcon.init(parameters: makeParameter(.foraBankID)))
    }
    
    func test_getHeaderIconForParameters_sfpBankWithEmptyVal_returnsSbpIcon() {
        
        XCTAssertEqual(PPIcon.init(parameters: makeParameter(""))?.equatable, .testSBPIcon)
    }
    
    func test_getHeaderIconForParameters_hasSfpBankAndIncorrectParameter_returnsSbpIcon() {
        
        XCTAssertEqual(PPIcon.init(parameters: makeParametersWithFora())?.equatable, .testSBPIcon)
    }
    
    // Success View
    
    func test_sfpLogo_sfpOperation_foraBank_returnsNil() {
        
        XCTAssertNil(PPLogo.sfpLogo(with: .sfpOperation(bankId: BankID.foraBankID.rawValue)))
    }
    
    func test_sfpLogo_sfpOperation_notForaBank_returnsSfpIcon() {
        
        XCTAssertEqual(PPLogo.sfpLogo(with: .sfpOperation(bankId: "otherBankId"))?.icon.equatable, EquatableParameterSuccessLogoIcon(.sfp))
    }
    
    func test_sfpLogo_notSfpOperation_returnsNil() {
        
        XCTAssertNil(PPLogo.sfpLogo(with: .nonSfpOperation()))
    }
    
    func test_sfpLogo_nilSource_returnsNil() {
        
        let operation = Payments.Operation(service: .sfp)
        XCTAssertNil(PPLogo.sfpLogo(with: operation))
    }
    
    func test_sfpLogo_notRemoteStartStep_returnsNil() {
        
        let steps = [Payments.Operation.Step(parameters: [], front: .empty(), back: .empty(stage: .remote(.confirm)))]
        XCTAssertNil(PPLogo.sfpLogo(with: .sfpOperation(bankId: "otherBankId", steps: steps)))
    }
    
    func test_bankParameter_sourceTemplatePayment_shouldReturnParameter() {
        
        let sut = makeSUT(
            Payments.Operation(
                service: .sfp,
                source: .template(2513)
            ),
            paymentTemplates: [
                .mobile10Digits
            ]
        )
        
        XCTAssertNoDiff(sut.parameter.id, Self.bankParameterTest.id)
    }
    
    func test_bankParameter_sourceTemplatePayment_shouldReturnParameterWithOutTemplate() {
        
        let sut = makeSUT(
            Payments.Operation(
                service: .sfp,
                source: .template(2513)
            ),
            paymentTemplates: []
        )
        
        XCTAssertNoDiff(sut.parameter.id, Self.bankParameterTest.id)
    }
    
    func test_bankParameter_sourceTemplatePayment_transferGeneralData_shouldReturnParameter() {
        
        let sut = makeSUT(
            Payments.Operation(
                service: .sfp,
                source: .template(2513)
            ),
            paymentTemplates: [
                Model.templateSFPStub([Model.transferGeneralDataStub()])
            ]
        )
        
        XCTAssertNoDiff(sut.parameter.id, Self.bankParameterTest.id)
    }
    
    func test_bankParameter_sourceTemplatePayment_transferData_shouldReturnParameter() {
        
        let sut = makeSUT(
            Payments.Operation(
                service: .sfp,
                source: .template(2513)
            ),
            paymentTemplates: [
                makeTemplate(templateID: 1, payerAccountID: nil)
            ]
        )
        
        XCTAssertNoDiff(sut.parameter.id, Self.bankParameterTest.id)
    }
    
    func test_createBankParameterForTemplate_shouldReturnParameterValueNil() {
        
        let sut = makeBankParameterSUT(paymentTemplates: [
            makeTemplate(templateID: 1, payerAccountID: nil)
        ])
        
        XCTAssertNoDiff(sut.value, nil)
    }
    
    func test_createBankParameterForTemplate_paymentTemplatesIsEmpty_shouldReturnParameter() {
        
        let sut = makeBankParameterSUT(paymentTemplates: [])
        XCTAssertNoDiff(sut.value, nil)
    }
    
    func test_createBankParameterForTemplate_paymentTemplateswithTransferAnywayData_shouldReturnParameter() {
        
        let sut = makeBankParameterSUT(
            paymentTemplates: [
                makeTemplate(templateID: 1, payerAccountID: nil)
            ],
            transferData: [
                TransferAnywayData.transferAnywayDataStub(
                    additional: [.init(fieldid: 1, fieldname: "RecipientID", fieldvalue: "123")]
                )
            ])
        
        XCTAssertNoDiff(sut.value, nil)
    }
    
    func test_createBankParameterForTemplate_paymentTemplateswithTransferGeneralData_shouldReturnParameter() {
        
        let sut = makeBankParameterSUT(
            paymentTemplates: [
                makeTemplate(templateID: 1, payerAccountID: nil)
            ],
            transferData: TransferGeneralData.generalStub(phoneNumber: "123")
        )
        
        XCTAssertNoDiff(sut.value, nil)
    }
    
    func test_createBankParameterForTemplate_paymentTemplateswithTransferMeToMeData_shouldReturnParameter() {
        
        let sut = makeBankParameterSUT(
            paymentTemplates: [
                makeTemplate(templateID: 1, payerAccountID: nil)
            ],
            transferData: TransferMe2MeData.me2MeStub()
        )
        
        XCTAssertNoDiff(sut.value, nil)
    }
    
    // MARK: - Helpers
    private typealias PPIcon = Payments.ParameterHeader.Icon
    private typealias PPLogo = Payments.ParameterSuccessLogo
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sut: Model = .mockWithEmptyExcept()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func makeBankParameterSUT(
        paymentTemplates: [PaymentTemplateData],
        transferData: [TransferData]? = nil
    ) -> Payments.ParameterSelectBank {
        
        let model: Model = .mockWithOperatorsList
        model.paymentTemplates.value = [Model.templateSFPStub(transferData ?? [])]
        
        return model.createBankParameterForTemplate(1, nil, nil, nil)
    }
    
    func makeSUT(
        _ operation: Payments.Operation,
        paymentTemplates: [PaymentTemplateData]
    ) -> Payments.ParameterSelectBank {
        
        let model: Model = .mockWithEmptyExcept()
        model.bankList.value = [.dummy(id: "1", bankType: .sfp, bankCountry: "RU")]
        
        let bankParameter = model.createBankParameter(
            latestPaymentBankIds: nil,
            operation,
            operationPhone: nil,
            banksIds: []
        )
        
        return bankParameter
    }
    
    private func makeTemplate(
        templateID: Int,
        payerAccountID: Int?
    ) -> PaymentTemplateData {
        
        .templateStub(
            paymentTemplateId: templateID,
            type: .betweenTheir,
            parameterList: [
                .init(
                    amount: nil,
                    check: true,
                    comment: nil,
                    currencyAmount: nil,
                    payer: payerAccountID.map { .test(accountId: $0) }
                )
            ]
        )
    }
    
    private func makeSPFSource(bankID: String = .foraBankID) -> Payments.Operation.Source {
        
        return .sfp(phone: "123", bankId: bankID)
    }
    
    private func makeParameter(_ value: String? = nil) -> [PaymentsParameterRepresentable] {
        
        let value = value ?? .testParamaterValue
        return [Payments.ParameterSelectBank.getTestParametersWithFora(value: value)]
    }
    
    
    private func makeParametersWithFora() -> [PaymentsParameterRepresentable] {
        
        let testParameter1 = Payments.ParameterSelectBank.getTestParametersWithFora()
        let testParameter2 = Payments.ParameterSelectBank.getTestParametersWithFora(
            bankID: "bankId",
            value: "value",
            name: "name"
        )
        
        return [testParameter1, testParameter2]
    }
}

extension Model_PaymensSFPTests {
    
    private static let bankParameterTest = Payments.ParameterSelectBank(
        .init(id: Payments.Parameter.Identifier.sfpBank.rawValue, value: nil),
        icon: .iconPlaceholder,
        title: "Банк получателя",
        options: [],
        placeholder: "Начните ввод для поиска",
        selectAll: .init(type: .banks),
        keyboardType: .normal
    )
}

extension Model {
    
    func hasTemplate(withID templateID: Int) -> Bool {
        
        paymentTemplates.value.first { $0.id == templateID } != nil
    }
}

private struct EquatableIcon: Equatable {
    
    enum Value: Equatable {
        
        case image(ImageData)
        case name(String)
    }
    
    let value: Value
    
    init(_ icon: Payments.ParameterHeader.Icon) {
        switch icon {
        case .image(let imageData):
            self.value = .image(imageData)
        case .name(let name):
            self.value = .name(name)
        }
    }
}

private extension EquatableIcon {
    
    static let testSBPIcon: Self = .init(.name("ic24Sbp"))
}

private extension Payments.ParameterHeader.Icon {
    
    var equatable: EquatableIcon {
        
        return EquatableIcon(self)
    }
}

private extension String {
    
    static let foraBankID = BankID.foraBankID.rawValue
    static let testParamaterValue = "1crt88888881"
}

private extension Payments.ParameterHeader.Icon {
    
    static let testSBPIcon: Self = .name("ic24Sbp")
}

private extension Payments.ParameterSelectBank {
    
    static func getTestParametersWithFora(
        bankID: String = "BankRecipientID",
        value: String = "1crt88888881",
        name: String = "ФОРА-БАНК",
        optionID: String = .foraBankID
    ) -> PaymentsParameterRepresentable {
        
        Payments.ParameterSelectBank(
            .init(
                id: bankID,
                value: value
            ),
            icon: .empty,
            title: "Банк получателя",
            options: [
                .init(id: optionID, name: name, subtitle: nil, icon: .empty, isFavorite: false, searchValue: name)
            ],
            placeholder: "Начните ввод для поиска",
            keyboardType: .normal
        )
    }
}

private struct EquatableParameterSuccessLogoIcon: Equatable {
    
    private let icon: Payments.ParameterSuccessLogo.Icon
    
    init(_ icon: Payments.ParameterSuccessLogo.Icon) {
        self.icon = icon
    }
    
    static func == (lhs: EquatableParameterSuccessLogoIcon, rhs: EquatableParameterSuccessLogoIcon) -> Bool {
        switch (lhs.icon, rhs.icon) {
        case (.sfp, .sfp):
            return true
        default:
            return false
        }
    }
}

private extension Payments.ParameterSuccessLogo.Icon {
    
    var equatable: EquatableParameterSuccessLogoIcon {
        return EquatableParameterSuccessLogoIcon(self)
    }
}

private extension Payments.Operation {
    static func sfpOperation(
        phone: String = "123",
        bankId: String,
        steps: [Step] = [.init(parameters: [], front: .empty(), back: .empty(stage: .remote(.start)))],
        visible: [String] = []
    ) -> Payments.Operation {
        return Payments.Operation(service: .sfp, source: .sfp(phone: phone, bankId: bankId), steps: steps, visible: visible)
    }
    
    static func nonSfpOperation() -> Payments.Operation {
        return Payments.Operation(service: .avtodor, source: .avtodor)
    }
}

private extension Payments.ParameterSuccessLogo {
    static func makeIcon(_ icon: Payments.ParameterSuccessLogo.Icon?) -> Payments.ParameterSuccessLogo? {
        return icon.map { Payments.ParameterSuccessLogo(icon: $0) }
    }
}


extension Model {
    
    static func anywayTransferDataStub(
        _ additional: [TransferAnywayData.Additional] = [.init(fieldid: 1, fieldname: "RecipientID", fieldvalue: "123")]
    ) -> TransferAnywayData {
        
        .init(
            amount: Decimal?.none,
            check: true,
            comment: nil,
            currencyAmount: "RUB",
            payer: .test(),
            additional: additional,
            puref: nil
        )
    }
    
    func generalTransferDataStub() -> TransferGeneralData {
        
        Model.transferGeneralDataStub(amount: nil, phoneNumber: "phone")
    }
    
    static func transferGeneralDataStub(
        amount: Double? = nil,
        phoneNumber: String? = nil
    ) -> TransferGeneralData {
        
        .init(
            amount: amount,
            check: false,
            comment: nil,
            currencyAmount: "", payer: .init(
                inn: nil,
                accountId: nil,
                accountNumber: nil,
                cardId: nil,
                cardNumber: nil,
                phoneNumber: phoneNumber),
            payeeExternal: nil,
            payeeInternal: nil)
    }
    
    static func templateSFPStub(
        _ transferData: [TransferData]
    ) -> PaymentTemplateData {
    
        return .init(
            groupName: "groupName",
            name: "name",
            parameterList: transferData,
            paymentTemplateId: 1,
            productTemplate: nil,
            sort: 1,
            svgImage: .test,
            type: .sfp
        )
    }
}
