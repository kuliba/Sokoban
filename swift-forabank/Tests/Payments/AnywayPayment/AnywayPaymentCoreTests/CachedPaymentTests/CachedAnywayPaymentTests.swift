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
    
    func test_init_shouldCreateInstanceWithNilInfoMessageFromAnywayPaymentWithNilInfoMessage() {
        
        let anywayPayment = makeAnywayPayment(infoMessage: nil)
        
        XCTAssertNil(Payment(anywayPayment).infoMessage)
    }
    
    func test_init_shouldCreateInstanceWithInfoMessageFromAnywayPaymentWithInfoMessage() {
        
        let infoMessage = anyMessage()
        let anywayPayment = makeAnywayPayment(infoMessage: infoMessage)
        
        XCTAssertNoDiff(Payment(anywayPayment).infoMessage, infoMessage)
    }
    
    func test_init_shouldCreateInstanceWithIsFinalStepFalseFromAnywayPaymentWithIsFinalStepFalse() {
        
        let anywayPayment = makeAnywayPayment(isFinalStep: false)
        
        XCTAssertFalse(Payment(anywayPayment).isFinalStep)
    }
    
    func test_init_shouldCreateInstanceWithIsFinalStepTrueFromAnywayPaymentWithIsFinalStepTrue() {
        
        let anywayPayment = makeAnywayPayment(isFinalStep: true)
        
        XCTAssertTrue(Payment(anywayPayment).isFinalStep)
    }
    
    func test_init_shouldCreateInstanceWithIsFraudSuspectedFalseFromAnywayPaymentWithIsFraudSuspectedFalse() {
        
        let anywayPayment = makeAnywayPayment(isFraudSuspected: false)
        
        XCTAssertFalse(Payment(anywayPayment).isFraudSuspected)
    }
    
    func test_init_shouldCreateInstanceWithIsFraudSuspectedTrueFromAnywayPaymentWithIsFraudSuspectedTrue() {
        
        let anywayPayment = makeAnywayPayment(isFraudSuspected: true)
        
        XCTAssertTrue(Payment(anywayPayment).isFraudSuspected)
    }
    
    func test_init_shouldCreateInstanceWithPurefFromAnywayPaymentWithPuref() {
        
        let puref = anyMessage()
        let anywayPayment = makeAnywayPayment(puref: .init(puref))
        
        XCTAssertNoDiff(Payment(anywayPayment).puref.rawValue, puref)
    }
    
    func test_init_shouldCreateInstanceWithEmptyModelsFromAnywayPaymentWithEmptyElements() {
        
        let anywayPayment = makeAnywayPayment(elements: [])
        
        let payment = Payment(anywayPayment)
        
        XCTAssertTrue(payment.models.isEmpty)
    }
    
    func test_init_shouldCreateInstanceWithModelsFromAnywayPaymentWithElements() {
        
        let field = makeAnywayPaymentField()
        let parameter = makeAnywayPaymentParameter()
        let core = makeAnywayPaymentCoreWidget()
        let anywayPayment = makeAnywayPayment(
            elements: [.field(field), .parameter(parameter), .widget(.core(core))]
        )
        
        let payment = Payment(anywayPayment)
        
        XCTAssertNoDiff(payment.models.map(\.id), [.fieldID(field.id), .parameterID(parameter.field.id), .widgetID(.core)])
        XCTAssertNoDiff(payment.models.map(\.model), [.field(field), .parameter(parameter), .widget(.core(core))])
    }
    
    func test_init_shouldMapElements() {
        
        struct Model: Equatable {}
        
        let field = makeAnywayPaymentField()
        let anywayPayment = makeAnywayPayment(elements: [.field(field)])
        
        let payment = CachedAnywayPayment<Model>(anywayPayment, using: { _ in .init() })
        
        XCTAssertNoDiff(payment.models.map(\.model), [.init()])
    }
    
    // MARK: - updating
    
    func test_updating_shouldUpdateWithNilInfoMessageFromAnywayPaymentWithNilInfoMessage() {
        
        let payment = Payment(makeAnywayPayment(infoMessage: anyMessage()))
        XCTAssertNotNil(payment.infoMessage)
        
        let updated = updating(payment, with: makeAnywayPayment(infoMessage: nil))
        
        XCTAssertNil(updated.infoMessage)
    }
    
    func test_updating_shouldUpdateWithInfoMessageFromAnywayPaymentWithInfoMessage() {
        
        let payment = Payment(makeAnywayPayment(infoMessage: nil))
        XCTAssertNil(payment.infoMessage)
        
        let infoMessage = anyMessage()
        let updated = updating(payment, with: makeAnywayPayment(infoMessage: infoMessage))
        
        XCTAssertNoDiff(updated.infoMessage, infoMessage)
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
    
    func test_updating_shouldUpdateWithIsFraudSuspectedFalseFromAnywayPaymentWithIsFraudSuspectedFalse() {
        
        let payment = Payment(makeAnywayPayment(isFraudSuspected: true))
        XCTAssertTrue(payment.isFraudSuspected)
        
        let updated = updating(payment, with: makeAnywayPayment(isFraudSuspected: false))
        
        XCTAssertFalse(updated.isFraudSuspected)
    }
    
    func test_updating_shouldUpdateIsFraudSuspectedTrueFromAnywayPaymentIsFraudSuspectedTrue() {
        
        let payment = Payment(makeAnywayPayment(isFraudSuspected: false))
        XCTAssertFalse(payment.isFraudSuspected)
        
        let updated = updating(payment, with: makeAnywayPayment(isFraudSuspected: true))
        
        XCTAssertTrue(updated.isFraudSuspected)
    }
    
    func test_updating_shouldUpdateWithPurefFromAnywayPaymentWithPuref() {
        
        let puref1 = anyMessage()
        let payment = Payment(makeAnywayPayment(puref: .init(puref1)))
        XCTAssertNoDiff(payment.puref, .init(puref1))
        
        let puref2 = anyMessage()
        let updated = updating(payment, with: makeAnywayPayment(puref: .init(puref2)))
        
        XCTAssertNoDiff(updated.puref, .init(puref2))
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
        let core = makeAnywayPaymentCoreWidget()
        let anywayPayment = makeAnywayPayment(
            elements: [.field(field), .parameter(parameter), .widget(.core(core))]
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
    
    private func makeAnywayPayment(
        elements: [AnywayElement] = [],
        infoMessage: String? = nil,
        isFinalStep: Bool = true,
        isFraudSuspected: Bool = true,
        puref: AnywayPayment.Puref = "abc||123"
    ) -> AnywayPayment {
        
        return .init(
            elements: elements,
            infoMessage: infoMessage,
            isFinalStep: isFinalStep,
            isFraudSuspected: isFraudSuspected,
            puref: puref
        )
    }
    
    private func updating(
        _ payment: Payment,
        with anywayPayment: AnywayPayment
    ) -> Payment {
        
        return payment.updating(with: anywayPayment, using: { $0 })
    }
}

private extension CachedAnywayPayment where ElementModel == AnywayElement {
    
    init(_ payment: AnywayPayment) {
        
        self.init(payment, using: { $0 })
    }
}

private func makeAnywayPaymentCoreWidget(
    amount: Decimal = .init(Double.random(in: 1...1_000)),
    currency: String = "RUB",
    productID: AnywayElement.Widget.PaymentCore.ProductID = .random(in: 1...1_000),
    productType: AnywayElement.Widget.PaymentCore.ProductType = .account
) -> AnywayElement.Widget.PaymentCore {
    
    return .init(
        amount: amount,
        currency: currency,
        productID: productID,
        productType: productType
    )
}
