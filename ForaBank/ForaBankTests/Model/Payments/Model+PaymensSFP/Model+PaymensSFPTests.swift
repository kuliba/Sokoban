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
        
        let source = makeSPFSource(bankID: .foraBankId)
        let icon = PPIcon.headerIconForOperationSource(source)
        
        XCTAssertNil(icon)
    }
    
    func test_getHeaderIconForOperation_sfpNonForaBank_returnsSbpIcon() {
        
        let source = makeSPFSource(bankID: "123123123")
        let icon = PPIcon.headerIconForOperationSource(source)
        
        XCTAssertEqual(icon, .testSBPIcon)
    }
    
    func test_getHeaderIconForOperation_otherSource_returnsSbpIcon() {
        
        let source = Payments.Operation.Source.avtodor
        let icon = PPIcon.headerIconForOperationSource(source)
        
        XCTAssertEqual(icon, .testSBPIcon)
    }
    
    func test_getHeaderIconForOperation_nilSource_returnsSbpIcon() {
        
        let icon = PPIcon.headerIconForOperationSource(nil)
        
        XCTAssertEqual(icon, .testSBPIcon)
    }
    
    func test_getHeaderIconForParameters_emptyParameters_returnsNil() {
        
        let icon = PPIcon.headerIconForBankParameters([])
        
        XCTAssertNil(icon)
    }
    
    func test_getHeaderIconForParameters_sfpBankNotFora_returnsSbpIcon() {
        
        let icon = PPIcon.headerIconForBankParameters(makeParameter())
        
        XCTAssertEqual(icon, .testSBPIcon)
    }
    
    func test_getHeaderIconForParameters_sfpBankIsFora_returnsNil() {
        
        let icon = PPIcon.headerIconForBankParameters(makeParameter(.foraBankId))
        
        XCTAssertNil(icon)
    }
    
    func test_getHeaderIconForParameters_sfpBankWithEmptyVal_returnsSbpIcon() {
        
        let icon = PPIcon.headerIconForBankParameters(makeParameter(""))
        
        XCTAssertEqual(icon, .testSBPIcon)
    }
    
    func test_getHeaderIconForParameters_hasSfpBankAndIncorrectParameter_returnsSbpIcon() {
        
        let icon = PPIcon.headerIconForBankParameters(makeParametersWithFora())
        
        XCTAssertEqual(icon, .testSBPIcon)
    }
    
    // MARK: - Helpers
    private typealias PPIcon = Payments.ParameterHeader.Icon
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let sut: Model = .mockWithEmptyExcept()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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
    
    private func makeSPFSource(bankID: String) -> Payments.Operation.Source {
        
        .sfp(phone: "123", bankId: bankID)
    }
    
    private func makeParameter(_ value: String = "1crt88888881") -> [PaymentsParameterRepresentable] {
        
        [Payments.ParameterSelectBank.getTestParametersWithFora(value: value)]
    }
    
    private func makeParametersWithFora() -> [PaymentsParameterRepresentable] {
        
        let testParameter1 = Payments.ParameterSelectBank.getTestParametersWithFora()
        let testParameter2 = Payments.ParameterSelectBank.getTestParametersWithFora(
            bankId: "bankId",
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
