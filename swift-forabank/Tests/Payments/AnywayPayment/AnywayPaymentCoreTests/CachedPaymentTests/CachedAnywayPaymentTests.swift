//
//  CachedAnywayPaymentTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 06.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class CachedAnywayPaymentTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldSetFooterToContinueOnContinue() {
        
        let anywayPayment = makeAnywayPayment(footer: .continue)
        
        XCTAssertNoDiff(Payment(anywayPayment).footer, .continue)
    }
    
    func test_init_shouldSetFooterToContinueOnAmountWithoutProduct() {
        
        let anywayPayment = makeAnywayPayment(
            amount: anyAmount(),
            footer: .amount
        )
        
        XCTAssertNoDiff(Payment(anywayPayment).footer, .continue)
    }
    
    func test_init_shouldSetFooterToAmountWithCurrencyOnAmountWithProduct() {
        
        let (amount, currency) = (anyAmount(), anyMessage())
        let product = makeProductWidget(currency: currency)
        let anywayPayment = makeAnywayPayment(
            amount: amount,
            elements: [.widget(.product(product))],
            footer: .amount
        )
        
        XCTAssertNoDiff(
            Payment(anywayPayment).footer,
            .amount(.init(amount: amount, currency: currency))
        )
    }
    
    func test_init_shouldCreateInstanceWithIsFinalStepFalseFromAnywayPaymentWithIsFinalStepFalse() {
        
        let anywayPayment = makeAnywayPayment(isFinalStep: false)
        
        XCTAssertFalse(Payment(anywayPayment).isFinalStep)
    }
    
    func test_init_shouldCreateInstanceWithIsFinalStepTrueFromAnywayPaymentWithIsFinalStepTrue() {
        
        let anywayPayment = makeAnywayPayment(isFinalStep: true)
        
        XCTAssertTrue(Payment(anywayPayment).isFinalStep)
    }
    
    func test_init_shouldCreateInstanceWithEmptyModelsFromAnywayPaymentWithEmptyElements() {
        
        let anywayPayment = makeAnywayPayment(elements: [])
        
        let payment = Payment(anywayPayment)
        
        XCTAssertTrue(payment.models.isEmpty)
    }
    
    func test_init_shouldCreateInstanceWithModelsFromAnywayPaymentWithElements() {
        
        let field = makeAnywayPaymentField()
        let parameter = makeAnywayPaymentParameter()
        let core = makeProductWidget()
        let anywayPayment = makeAnywayPayment(
            elements: [.field(field), .parameter(parameter), .widget(.product(core))]
        )
        
        let payment = Payment(anywayPayment)
        
        XCTAssertNoDiff(payment.models.map(\.id), [.fieldID(field.id), .parameterID(parameter.field.id), .widgetID(.product)])
        XCTAssertNoDiff(payment.models.map(\.model), [.field(field), .parameter(parameter), .widget(.product(core))])
    }
    
    func test_init_shouldMapElements() {
        
        struct Model: Equatable {}
        
        let field = makeAnywayPaymentField()
        let anywayPayment = makeAnywayPayment(elements: [.field(field)])
        
        let payment = CachedAnywayPayment<Model>(anywayPayment, using: { _ in .init() })
        
        XCTAssertNoDiff(payment.models.map(\.model), [.init()])
    }
    
    // MARK: - updating
    
    func test_updating_shouldNotChangeFooterWithoutCurrencyOnSameAmount() {
        
        let amount = anyAmount()
        let payment = Payment(makeAnywayPayment(amount: amount))
        XCTAssertNoDiff(payment.footer, .continue)
        
        let updated = updating(payment, with: makeAnywayPayment(amount: amount))
        
        XCTAssertNoDiff(updated.footer, .continue)
    }
    
    func test_updating_shouldSetFooterWithCurrencyOnSameAmountWithProduct() {
        
        let (amount, currency) = (anyAmount(), anyMessage())
        let product = makeProductWidget(currency: currency)
        let payment = Payment(makeAnywayPayment(
            amount: amount
        ))
        XCTAssertNoDiff(payment.footer, .continue)
        
        let updated = updating(payment, with: makeAnywayPayment(
            amount: amount,
            elements: [.widget(.product(product))],
            footer: .amount
        ))
        
        XCTAssertNoDiff(
            updated.footer,
            .amount(.init(amount: amount, currency: currency))
        )
    }
    
    func test_updating_shouldNotChangeFooterOnSameContinue() {
        
        let payment = Payment(makeAnywayPayment(footer: .continue))
        XCTAssertNoDiff(payment.footer, .continue)
        
        let updated = updating(payment, with: makeAnywayPayment(footer: .continue))
        
        XCTAssertNoDiff(updated.footer, .continue)
    }
    
    func test_updating_shouldSetFooterToContinueOnContinue() {
        
        let amount = anyAmount()
        let payment = Payment(makeAnywayPayment(amount: amount))
        XCTAssertNoDiff(payment.footer, .continue)
        
        let updated = updating(payment, with: makeAnywayPayment(footer: .continue))
        
        XCTAssertNoDiff(updated.footer, .continue)
    }
    
    func test_updating_shouldSetFooterToContinueOnUpdatedWithoutProduct() {
        
        let amount = anyAmount()
        let payment = Payment(makeAnywayPayment(footer: .continue))
        XCTAssertNoDiff(payment.footer, .continue)
        
        let updated = updating(payment, with: makeAnywayPayment(amount: amount))
        
        XCTAssertNoDiff(updated.footer, .continue)
    }
    
    func test_updating_shouldSetFooterToAmountWithCurrencyOnUpdatedWithProduct() {
        
        let (amount, currency) = (anyAmount(), anyMessage())
        let product = makeProductWidget(currency: currency)
        let payment = Payment(makeAnywayPayment(footer: .continue))
        XCTAssertNoDiff(payment.footer, .continue)
        
        let updated = updating(payment, with: makeAnywayPayment(
            amount: amount,
            elements: [.widget(.product(product))],
            footer: .amount
        ))
        
        XCTAssertNoDiff(
            updated.footer,
                .amount(.init(amount: amount, currency: currency))
        )
    }
    
    func test_updating_shouldUpdateWithIsFinalStepFalseFromAnywayPaymentWithIsFinalStepFalse() {
        
        let payment = Payment(makeAnywayPayment(isFinalStep: true))
        XCTAssertTrue(payment.isFinalStep)
        
        let updated = updating(payment, with: makeAnywayPayment(isFinalStep: false))
        
        XCTAssertFalse(updated.isFinalStep)
    }
    
    func test_updating_shouldUpdateIsFinalStepTrueFromAnywayPaymentIsFinalStepTrue() {
        
        let payment = Payment(makeAnywayPayment(isFinalStep: false))
        XCTAssertFalse(payment.isFinalStep)
        
        let updated = updating(payment, with: makeAnywayPayment(isFinalStep: true))
        
        XCTAssertTrue(updated.isFinalStep)
    }
    
    func test_updating_shouldUpdateWithEmptyModelsFromAnywayPaymentWithEmptyElements() {
        
        let payment = Payment(makeAnywayPayment(elements: [.field(makeAnywayPaymentField())]))
        XCTAssertFalse(payment.models.isEmpty)
        
        let updated = updating(payment, with: makeAnywayPayment(elements: []))
        
        XCTAssertTrue(updated.models.isEmpty)
    }
    
    func test_updating_shouldUpdateWithModelsFromAnywayPaymentWithElements() {
        
        let field = makeAnywayPaymentField()
        let parameter = makeAnywayPaymentParameter()
        let core = makeProductWidget()
        let anywayPayment = makeAnywayPayment(
            elements: [.field(field), .parameter(parameter), .widget(.product(core))]
        )
        let payment = Payment(anywayPayment)
        
        let updated = updating(payment, with: makeAnywayPayment(elements: [.parameter(parameter), .field(field)]))
        
        XCTAssertNoDiff(updated.models.map(\.id), [.parameterID(parameter.field.id), .fieldID(field.id)])
        XCTAssertNoDiff(updated.models.map(\.model), [.parameter(parameter), .field(field)])
    }
    
    func test_updating_shouldMapElements() {
        
        struct Model: Equatable {}
        
        let anywayPayment = makeAnywayPayment()
        let map: (AnywayElement) -> Model = { _ in .init() }
        let payment = CachedAnywayPayment<Model>(anywayPayment, using: map)
        XCTAssertTrue(payment.models.isEmpty)
        
        let updated = payment.updating(with: makeAnywayPayment(elements: [.field(makeAnywayPaymentField())]), using: map)
        
        XCTAssertNoDiff(updated.models.map(\.model), [.init()])
    }
    
    // MARK: - Helpers
    
    private typealias Payment = CachedAnywayPayment<ElementModel>
    private typealias ElementModel = AnywayElement
    
    private func updating(
        _ payment: Payment,
        with anywayPayment: AnywayPayment
    ) -> Payment {
        
        return payment.updating(with: anywayPayment, using: { $0 })
    }
    
    private func anyAmount(
        _ value: Decimal = .init(Double.random(in: 1...999))
    ) -> Decimal {
        
        return value
    }
}

private extension CachedAnywayPayment where ElementModel == AnywayElement {
    
    init(_ payment: AnywayPayment) {
        
        self.init(payment, using: { $0 })
    }
}
