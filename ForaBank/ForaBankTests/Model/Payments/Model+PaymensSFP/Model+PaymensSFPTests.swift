//
//  Model+PaymensSFPTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.09.2023.
//

@testable import ForaBank
import XCTest
import OTPInputComponentTests

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
    
    func test_foraBankID_isCorrect() {
        
        XCTAssertEqual(BankID.foraBankID.rawValue, "100000000217")
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
        
       // let icon = PPIcon.headerIconForBankParameters(makeParameter())
        
        XCTAssertEqual(PPIcon(parameters: makeParameter())?.equatable, .testSBPIcon)
    }
    
    func test_getHeaderIconForParameters_sfpBankIsFora_returnsNil() {
        
        //let icon = PPIcon.headerIconForBankParameters(makeParameter(.foraBankId))
        
        XCTAssertNil(PPIcon.init(parameters: makeParameter(.foraBankID)))
    }
    
    func test_getHeaderIconForParameters_sfpBankWithEmptyVal_returnsSbpIcon() {
        
        XCTAssertEqual(PPIcon.init(parameters: makeParameter(""))?.equatable, .testSBPIcon)
    }
    
    func test_getHeaderIconForParameters_hasSfpBankAndIncorrectParameter_returnsSbpIcon() {

        XCTAssertEqual(PPIcon.init(parameters: makeParametersWithFora())?.equatable, .testSBPIcon)
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
    
    static let testSBPIcon: Self = .init(.sbpIcon)
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
    
    static let testSBPIcon: Self = .sbpIcon
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
