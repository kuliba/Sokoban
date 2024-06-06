//
//  CachedAnywayPaymentTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 06.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import ForaTools

struct CachedAnywayPayment<ElementModel> {
    
    private let cachedModels: CachedModels
    let infoMessage: String?
    let isFinalStep: Bool
    let isFraudSuspected: Bool
    let puref: Puref
    
    private init(
        cachedModels: CachedModels,
        infoMessage: String?,
        isFinalStep: Bool,
        isFraudSuspected: Bool,
        puref: Puref
    ) {
        self.cachedModels = cachedModels
        self.infoMessage = infoMessage
        self.isFinalStep = isFinalStep
        self.isFraudSuspected = isFraudSuspected
        self.puref = puref
    }
    
    init(
        _ payment: AnywayPayment,
        using map: @escaping (Element) -> (ElementModel)
    ) {
        self.init(
            cachedModels: .init(pairs: payment.elements.map { ($0.id, map($0)) }),
            infoMessage: payment.infoMessage,
            isFinalStep: payment.isFinalStep,
            isFraudSuspected: payment.isFraudSuspected,
            puref: payment.puref
        )
    }
    
    var models: [IdentifiedModels] {
        
        cachedModels.keyModelPairs.map(IdentifiedModels.init)
    }
    
    struct IdentifiedModels: Identifiable {
        
        let id: Element.ID
        let model: ElementModel
    }
    
    typealias CachedModels = CachedModelsState<Element.ID, ElementModel>
    typealias Element = AnywayPayment.Element
    
    typealias Puref = AnywayPayment.Puref
    typealias AnywayPayment = AnywayPaymentDomain.AnywayPayment
}

@testable import ForaBank
import XCTest

private typealias AnywayPayment = AnywayPaymentDomain.AnywayPayment

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
        XCTAssertNoDiff(payment.models.map(\.model), anywayPayment.elements)
    }
    
    // MARK: - Helpers
    
    private typealias Payment = CachedAnywayPayment<ElementModel>
    private typealias ElementModel = AnywayPayment.Element
    
    private func makeAnywayPayment(
        elements: [AnywayPayment.Element] = [],
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
}

private extension CachedAnywayPayment where ElementModel == AnywayPayment.Element {
    
    init(_ payment: AnywayPayment) {
        
        self.init(payment, using: { $0 })
    }
}

private func makeAnywayPaymentField(
    id: String = anyMessage(),
    title: String = anyMessage(),
    value: String = anyMessage(),
    image: AnywayPayment.Element.Image? = nil
) -> AnywayPayment.Element.Field {
    
    return .init(
        id: .init(id),
        title: title,
        value: .init(value),
        image: image
    )
}

private func makeAnywayPaymentParameter(
    field: AnywayPayment.Element.Parameter.Field = makeAnywayPaymentParameterField(),
    image: AnywayPayment.Element.Image? = nil,
    masking: AnywayPayment.Element.Parameter.Masking = makeAnywayPaymentParameterMasking(),
    validation: AnywayPayment.Element.Parameter.Validation = makeAnywayPaymentParameterValidation(),
    uiAttributes: AnywayPayment.Element.Parameter.UIAttributes = makeAnywayPaymentParameterUIAttributes()
) -> AnywayPayment.Element.Parameter {
    
    return .init(
        field: field,
        image: image,
        masking: masking,
        validation: validation,
        uiAttributes: uiAttributes
    )
}

private func makeAnywayPaymentParameterField(
    id: String = anyMessage(),
    value: String? = nil
) -> AnywayPayment.Element.Parameter.Field {
    
    return .init(id: .init(id), value: value.map { .init($0) })
}

private func makeAnywayPaymentParameterMasking(
    inputMask: String? = nil,
    mask: String? = nil
) -> AnywayPayment.Element.Parameter.Masking {
    
    return .init(inputMask: inputMask, mask: mask)
}

private func makeAnywayPaymentParameterValidation(
    isRequired: Bool = true,
    maxLength: Int? = nil,
    minLength: Int? = nil,
    regExp: String = anyMessage()
) -> AnywayPayment.Element.Parameter.Validation {
    
    return .init(
        isRequired: isRequired,
        maxLength: maxLength,
        minLength: minLength,
        regExp: regExp
    )
}

private func makeAnywayPaymentParameterUIAttributes(
    dataType: AnywayPayment.Element.Parameter.UIAttributes.DataType = .number,
    group: String? = nil,
    isPrint: Bool = false,
    phoneBook: Bool = false,
    isReadOnly: Bool = false,
    subGroup: String? = nil,
    subTitle: String? = nil,
    title: String = anyMessage(),
    type: AnywayPayment.Element.Parameter.UIAttributes.FieldType = .input,
    viewType: AnywayPayment.Element.Parameter.UIAttributes.ViewType = .input
) -> AnywayPayment.Element.Parameter.UIAttributes {
    
    return .init(
        dataType: dataType,
        group: group,
        isPrint: isPrint,
        phoneBook: phoneBook,
        isReadOnly: isReadOnly,
        subGroup: subGroup,
        subTitle: subTitle,
        title: title,
        type: type,
        viewType: viewType
    )
}

private func makeAnywayPaymentCoreWidget(
    amount: Decimal = .init(Double.random(in: 1...1_000)),
    currency: String = "RUB",
    productID: AnywayPayment.Element.Widget.PaymentCore.ProductID = .accountID(.init(.random(in: 1...1_000)))
) -> AnywayPayment.Element.Widget.PaymentCore {
    
    return .init(amount: amount, currency: .init(currency), productID: productID)
}

func anyMessage() -> String {
    
    UUID().uuidString
}
