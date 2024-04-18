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
    
    typealias PPIcon = Payments.ParameterHeader.Icon
    
    func test_getHeaderIconForOperation_sfpForaBank_returnsNil() {
        
        let source = Payments.Operation.Source.sfp(phone: "123", bankId: .foraBankId)
        let sut: Model = .mockWithEmptyExcept()
        let icon = sut.getHeaderIconForOperation(source: source)
        
        XCTAssertNil(icon)
    }
    
    func test_getHeaderIconForOperation_sfpNonForaBank_returnsSbpIcon() {
        
        let source = Payments.Operation.Source.sfp(phone: "123", bankId: "123123123")
        let sut: Model = .mockWithEmptyExcept()
        let icon = sut.getHeaderIconForOperation(source: source)
        
        XCTAssertEqual(icon, .testSBPIcon)
    }
    
    func test_getHeaderIconForOperation_otherSource_returnsSbpIcon() {
        
        let source = Payments.Operation.Source.avtodor
        let sut: Model = .mockWithEmptyExcept()
        let icon = sut.getHeaderIconForOperation(source: source)
        
        XCTAssertEqual(icon, .testSBPIcon)
    }
    
    func test_getHeaderIconForOperation_nilSource_returnsSbpIcon() {
        
        let source: Payments.Operation.Source? = nil
        let sut: Model = .mockWithEmptyExcept()
        let icon = sut.getHeaderIconForOperation(source: source)
        
        XCTAssertEqual(icon, .testSBPIcon)
    }
    
    func test_getHeaderIconForParameters_emptyParameters_returnsNil() {
        
        let parameters: [PaymentsParameterRepresentable] = []
        let sut: Model = .mockWithEmptyExcept()
        let icon = sut.getHeaderIconForParameters(parameters)
        
        XCTAssertNil(icon)
    }
    
    func test_getHeaderIconForParameters_sfpBankNotFora_returnsSbpIcon() {
        
        let parameter = Payments.ParameterSelectBank.getTestParametersWithFora()
        let parameters: [PaymentsParameterRepresentable] = [parameter]
        let sut: Model = .mockWithEmptyExcept()
        let icon = sut.getHeaderIconForParameters(parameters)
        
        XCTAssertEqual(icon, .testSBPIcon)
    }
    
    func test_getHeaderIconForParameters_sfpBankIsFora_returnsNil() {
        
        let parameter = Payments.ParameterSelectBank.getTestParametersWithFora(value: .foraBankId)
        let parameters: [PaymentsParameterRepresentable] = [parameter]
        let sut: Model = .mockWithEmptyExcept()
        let icon = sut.getHeaderIconForParameters(parameters)
        
        XCTAssertNil(icon)
    }
    
    func test_getHeaderIconForParameters_sfpBankWithEmptyVal_returnsSbpIcon() {
        
        let parameter = Payments.ParameterSelectBank.getTestParametersWithFora(value: "")
        let parameters: [PaymentsParameterRepresentable] = [parameter]
        let sut: Model = .mockWithEmptyExcept()
        let icon = sut.getHeaderIconForParameters(parameters)
        
        XCTAssertEqual(icon, .testSBPIcon)
    }
    
    func test_getHeaderIconForParameters_hasSfpBankAndIncorrectParameter_returnsSbpIcon() {
        
        let testParameter1 = Payments.ParameterSelectBank.getTestParametersWithFora()
        let testParameter2 = Payments.ParameterSelectBank.getTestParametersWithFora(
            bankId: "bankId",
            value: "value",
            name: "name"
        )

        let parameters: [PaymentsParameterRepresentable] = [
            testParameter1, testParameter2
        ]
        let sut: Model = .mockWithEmptyExcept()
        let icon = sut.getHeaderIconForParameters(parameters)
        
        XCTAssertEqual(icon, .testSBPIcon)
    }
    
    // MARK: - Helpers
    
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

extension Payments.ParameterHeader.Icon: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.name(l), .name(r)):
            return l == r
        default:
            return false
        }
    }
}

private extension String {
    
    static let foraBankId = "100000000217"
}

private extension Payments.ParameterHeader.Icon {
    
    static let testSBPIcon: Self = .name("ic24Sbp")
}

private extension Payments.ParameterSelectBank {
    
    static func getTestParametersWithFora(
        bankId: String = "BankRecipientID",
        value: String = "1crt88888881",
        name: String = "ФОРА-БАНК",
        optionId: String = .foraBankId
    ) -> PaymentsParameterRepresentable {
        
        Payments.ParameterSelectBank(
            .init(
                id: bankId,
                value: value
            ),
            icon: .empty,
            title: "Банк получателя",
            options: [
                .init(id: optionId, name: name, subtitle: nil, icon: .empty, isFavorite: false, searchValue: name)
            ],
            placeholder: "Начните ввод для поиска",
            keyboardType: .normal
        )
    }
}
