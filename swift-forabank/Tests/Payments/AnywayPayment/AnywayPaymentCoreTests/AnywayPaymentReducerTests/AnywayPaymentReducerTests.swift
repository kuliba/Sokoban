//
//  AnywayPaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 20.05.2024.
//

import Tagged

enum AnywayPaymentEvent: Equatable {
    
    case setValue(String, for: ParameterID)
    case widget(Widget)
}

extension AnywayPaymentEvent {
    
    typealias ParameterID = AnywayPayment.Element.Parameter.Field.ID
    
    enum Widget: Equatable {
        
        case amount(Decimal)
        case otp(Int?)
        case product(ProductID, Currency)
    }
}

extension AnywayPaymentEvent.Widget {
    
    typealias Currency = AnywayPayment.Element.Widget.PaymentCore.Currency
    typealias ProductID = AnywayPayment.Element.Widget.PaymentCore.ProductID
}

extension AnywayPaymentEvent.Widget.ProductID {
    
    enum ProductType: Equatable {
        
        case account, card
    }
}

enum AnywayPaymentEffect: Equatable {}

final class AnywayPaymentReducer {}

extension AnywayPaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        
        switch event {
        case let .setValue(value, for: parameterID):
            reduce(&state, value, parameterID)
            
        case let .widget(widget):
            reduce(&state, widget)
        }
        
        return (state, nil)
    }
}

extension AnywayPaymentReducer {
    
    typealias State = AnywayPayment
    typealias Event = AnywayPaymentEvent
    typealias Effect = AnywayPaymentEffect
}

private extension AnywayPaymentReducer {
    
    func reduce(
        _ state: inout State,
        _ value: String,
        _ parameterID: Event.ParameterID
    ) {
        state.setValue(value, for: parameterID)
    }
    
    func reduce(
        _ state: inout State,
        _ widget: Event.Widget
    ) {
        switch widget {
        case let .amount(amount):
            state.update(with: amount)
            
        case let .otp(otp):
            state.update(otp: otp)
            
        case let .product(productID, currency):
            state.update(with: productID, and: currency)
        }
    }
}

import ForaTools

private extension AnywayPayment {
    
    mutating func setValue(
        _ value: String,
        for parameterID: ParameterID
    ) {
        guard let index = elements.firstIndex(matching: parameterID),
              case let .parameter(parameter) = elements[index]
        else { return }
        
        elements[index] = .parameter(parameter.updating(value: value))
    }
    
    typealias ParameterID = AnywayPayment.Element.Parameter.Field.ID
    
    mutating func update(
        with amount: Decimal
    ) {
        guard let index = elements.firstIndex(matching: .core),
              case let .widget(.core(core)) = elements[index]
        else { return }
        
        elements[index] = .widget(.core(core.updating(amount: amount)))
    }
    
    mutating func update(
        with productID: Element.Widget.PaymentCore.ProductID,
        and currency: Element.Widget.PaymentCore.Currency
    ) {
        guard let index = elements.firstIndex(matching: .core),
              case let .widget(.core(core)) = elements[index]
        else { return }
        
        elements[index] = .widget(.core(core.updating(with: productID, and: currency)))
    }
    
    mutating func update(
        otp: Int?
    ) {
        guard let index = elements.firstIndex(matching: .otp),
              case .widget(.otp) = elements[index]
        else { return }
        
        elements[index] = .widget(.otp(otp))
    }
}

private extension AnywayPayment.Element.Widget.PaymentCore {
    
    func updating(
        amount: Decimal
    ) -> Self {
        return .init(amount: amount, currency: currency, productID: productID)
    }
    
    func updating(
        with productID: ProductID,
        and currency: Currency
    ) -> Self {
        
        return .init(amount: amount, currency: currency, productID: productID)
    }
}

private extension Array where Element == AnywayPayment.Element {
    
    func firstIndex(matching id: ParameterID) -> Index? {
        
        firstIndex {
            
            switch $0 {
            case let .parameter(parameter):
                return parameter.field.id == id
                
            default:
                return false
            }
        }
    }
    
    typealias ParameterID = AnywayPayment.Element.Parameter.Field.ID
    
    func firstIndex(matching id: Element.Widget.ID) -> Index? {
        
        firstIndex {
            
            switch $0 {
            case let .widget(widget):
                return widget.id == id
                
            default:
                return false
            }
        }
    }
}

private extension AnywayPaymentReducer {}

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class AnywayPaymentReducerTests: XCTestCase {
    
    // MARK: - setValue
    
    func test_setValue_shouldNotChangeStateOnEmpty() {
        
        let missingID = makeParameterID()
        let state = makeEmptyState()
        
        assertState(.setValue(anyMessage(), for: missingID), on: state)
        assertMissingID(state, missingID)
    }
    
    func test_setValue_shouldNotDeliverEffectOnEmpty() {
        
        let missingID = makeParameterID()
        let state = makeEmptyState()
        
        assert(.setValue(anyMessage(), for: missingID), on: state, effect: nil)
        assertMissingID(state, missingID)
    }
    
    func test_setValue_shouldNotChangeStateOnMissingParameterID() {
        
        let missingID = makeParameterID()
        let state = makeState(
            elements: [makeAnywayPaymentParameterElement()]
        )
        
        assertState(.setValue(anyMessage(), for: missingID), on: state)
        assertMissingID(state, missingID)
    }
    
    func test_setValue_shouldNotDeliverEffectOnMissingParameterID() {
        
        let missingID = makeParameterID()
        let state = makeState(
            elements: [makeAnywayPaymentParameterElement()]
        )
        
        assert(.setValue(anyMessage(), for: missingID), on: state, effect: nil)
        assertMissingID(state, missingID)
    }
    
    func test_setValue_shouldChangeParameterValueForGivenID() {
        
        let value = anyMessage()
        let parameterID = makeParameterID()
        let parameter = makeAnywayPaymentParameter(id: parameterID.rawValue)
        let state = makeState(elements: [.parameter(parameter)])
        
        assertState(.setValue(value, for: parameterID), on: state) {
            
            let parameter = AnywayPayment.Element.Parameter(
                field: .init(
                    id: .init(parameterID.rawValue),
                    value: .init(value)
                ),
                masking: parameter.masking,
                validation: parameter.validation,
                uiAttributes: parameter.uiAttributes
            )
            $0.elements = [.parameter(parameter)]
        }
    }
    
    func test_setValue_shouldNotDeliverEffect() {
        
        let value = anyMessage()
        let parameterID = makeParameterID()
        let parameter = makeAnywayPaymentParameter(id: parameterID.rawValue)
        let state = makeState(elements: [.parameter(parameter)])
        
        assert(.setValue(value, for: parameterID), on: state, effect: nil)
    }
    
    // MARK: - widget
    
    func test_widget_amount_shouldNotChangeStateOnMissingAmount() {
        
        let state = makeEmptyState()
        
        assertState(.widget(.amount(anyAmount())), on: state)
        assertMissingID(state, .core)
    }
    
    func test_widget_amount_shouldNotDeliverEffectOnMissingAmount() {
        
        let state = makeEmptyState()
        
        assert(.widget(.amount(anyAmount())), on: state, effect: nil)
        assertMissingID(state, .core)
    }
    
    func test_widget_amount_shouldChangeStateOnAmount() {
        
        let amount = anyAmount()
        let core = makeCore()
        let state = makeState(elements: [.widget(.core(core))])
        
        assertState(.widget(.amount(amount)), on: state) {
            
            $0.elements = [.widget(.core(.init(
                amount: amount,
                currency: core.currency,
                productID: core.productID
            )))]
        }
    }
    
    func test_widget_amount_shouldNotDeliverEffectOnCore() {
        
        let state = makeState(elements: [.widget(.core(makeCore()))])
        
        assert(.widget(.amount(anyAmount())), on: state, effect: nil)
    }
    
    func test_widget_otp_shouldNotChangeStateOnMissingOTP() {
        
        let state = makeEmptyState()
        
        assertState(.widget(anyOTP()), on: state)
        assertMissingID(state, .otp)
    }
    
    func test_widget_otp_shouldNotDeliverEffectOnMissingOTP() {
        
        let state = makeEmptyState()
        
        assert(.widget(anyOTP()), on: state, effect: nil)
        assertMissingID(state, .otp)
    }
    
    func test_widget_otp_shouldChangeStateOnNilOTP() {
        
        let state = makeState(elements: [.widget(anyOTP())])
        
        assertState(.widget(.otp(nil)), on: state) {
            
            $0.elements = [.widget(.otp(nil))]
        }
    }
    
    func test_widget_otp_shouldNotDeliverEffectOnNil() {
        
        let state = makeState(elements: [.widget(anyOTP())])
        
        assert(.widget(.otp(nil)), on: state, effect: nil)
    }
    
    func test_widget_otp_shouldChangeStateOnOTP() {
        
        let otp = generateRandom11DigitNumber()
        let state = makeState(elements: [.widget(anyOTP())])
        
        assertState(.widget(.otp(otp)), on: state) {
            
            $0.elements = [.widget(.otp(otp))]
        }
    }
    
    func test_widget_otp_shouldNotDeliverEffectOnCore() {
        
        let state = makeState(elements: [.widget(anyOTP())])
        
        assert(.widget(anyOTP()), on: state, effect: nil)
    }
    
    func test_widget_product_shouldNotChangeStateOnMissingProduct() {
        
        let state = makeEmptyState()
        
        assertState(.widget(.product(anyProductID(), anyCurrency())), on: state)
        assertMissingID(state, .core)
    }
    
    func test_widget_product_shouldNotDeliverEffectOnMissingProduct() {
        
        let state = makeEmptyState()
        
        assertState(.widget(.product(anyProductID(), anyCurrency())), on: state)
        assertMissingID(state, .core)
    }
    
    func test_widget_product_shouldChangeStateOnProduct() {
        
        let productID = anyProductID()
        let currency = anyCurrency()
        let core = makeCore()
        let state = makeState(elements: [.widget(.core(core))])
        
        assertState(.widget(.product(productID, currency)), on: state) {
            
            $0.elements = [.widget(.core(.init(
                amount: core.amount,
                currency: currency,
                productID: productID
            )))]
        }
    }
    
    func test_widget_product_shouldNotDeliverEffectOnCore() {
        
        let state = makeState(elements: [.widget(.core(makeCore()))])
        
        assert(.widget(.product(anyProductID(), anyCurrency())), on: state, effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = AnywayPaymentReducer
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private typealias UpdateStateToExpected<State> = (_ state: inout State) -> Void
    
    private func assertState(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        updateStateToExpected: UpdateStateToExpected<State>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(expectedState), but got \(receivedState) instead.",
            file: file, line: line
        )
    }
    
    private func assert(
        sut: SUT? = nil,
        _ event: Event,
        on state: State,
        effect expectedEffect: Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
    
    private func assertMissingID(
        _ state: State,
        _ missingID: AnywayPayment.Element.Parameter.Field.ID,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let iDs = Set(state.elements.parameters.map(\.field.id))
        
        XCTAssertFalse(iDs.contains(missingID), "Expected id \(missingID) to be missing but was found in state \(state).", file: file, line: line)
    }
    
    private func assertMissingID(
        _ state: State,
        _ missingID: AnywayPayment.Element.Widget.ID,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let iDs = Set(state.elements.widgets.map(\.id))
        
        XCTAssertFalse(iDs.contains(missingID), "Expected id \(missingID) to be missing but was found in state \(state).", file: file, line: line)
    }
    
    private func makeParameterID(
        id: String = UUID().uuidString
    ) -> AnywayPayment.Element.Parameter.Field.ID {
        
        .init(id)
    }
    
    private func makeCore(
        amount: Decimal = anyAmount(),
        currency: AnywayPayment.Element.Widget.PaymentCore.Currency = "RUB",
        productID: AnywayPayment.Element.Widget.PaymentCore.ProductID = .accountID(.init(generateRandom11DigitNumber()))
    ) -> AnywayPayment.Element.Widget.PaymentCore {
        
        .init(amount: amount, currency: currency, productID: productID)
    }
    
    private func anyProductID(
        id: Int = generateRandom11DigitNumber()
    ) -> AnywayPaymentEvent.Widget.ProductID {
        
        return .accountID(.init(id))
    }
    
    private func anyCurrency(
        _ rawValue: String = anyMessage()
    ) -> AnywayPaymentEvent.Widget.Currency {
        
        .init(rawValue)
    }
    
    private func anyOTP(
        value: Int? = generateRandom11DigitNumber()
    ) -> AnywayPayment.Element.Widget {
        
        return .otp(value)
    }
    
    private func anyOTP(
        value: Int? = generateRandom11DigitNumber()
    ) -> AnywayPaymentEvent.Widget {
        
        return .otp(value)
    }
    
    private func makeEmptyState(
    ) -> State {
        
        let state = makeState(elements: [])
        precondition(state.elements.isEmpty)
        return state
    }
    
    private func makeState(
        elements: [AnywayPayment.Element],
        infoMessage: String? = nil,
        isFinalStep: Bool = false,
        isFraudSuspected: Bool = false,
        puref: AnywayPayment.Puref = .init(anyMessage())
    ) -> State {
        
        return .init(
            elements: elements,
            infoMessage: infoMessage,
            isFinalStep: isFinalStep,
            isFraudSuspected: isFraudSuspected,
            puref: puref
        )
    }
}

private func anyAmount(
    _ amount: Decimal = .init(generateRandom11DigitNumber())/100
) -> Decimal {
    
    return amount
}

private extension Array where Element == AnywayPayment.Element {
    
    var parameters: [AnywayPayment.Element.Parameter] {
        
        compactMap {
            
            guard case let .parameter(parameter) = $0 else { return nil }
            
            return parameter
        }
    }
    
    var widgets: [AnywayPayment.Element.Widget] {
        
        compactMap {
            
            guard case let .widget(widget) = $0 else { return nil }
            
            return widget
        }
    }
}
