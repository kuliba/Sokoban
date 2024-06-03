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
        let sut: Model = .mockWithEmptyExcept()
        
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
            let sut: Model = .mockWithEmptyExcept()
            
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
        let sut: Model = .mockWithEmptyExcept()
        
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
        let sut: Model = .mockWithEmptyExcept()
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
        
        let sut: Model = .mockWithEmptyExcept()
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
        
        let sut: Model = .mockWithEmptyExcept()
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
