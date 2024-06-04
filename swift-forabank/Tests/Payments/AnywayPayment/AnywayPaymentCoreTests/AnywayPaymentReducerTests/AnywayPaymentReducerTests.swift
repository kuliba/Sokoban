//
//  AnywayPaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 20.05.2024.
//

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
            
            let parameter = parameter.updating(value: value)
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
    
    func test_widget_otp_shouldSetOTPToNilOnNonDigitString() {
        
        let nonDigitString = anyNonDigitString()
        let state = makeState(elements: [.widget(anyOTP())])
        
        assertState(.widget(.otp(nonDigitString)), on: state) {
            
            $0.elements = [.widget(.otp(nil))]
        }
    }
    
    func test_widget_otp_shouldSetOTPToDigits() {
        
        let state = makeState(elements: [.widget(anyOTP())])
        
        assertState(.widget(.otp("abc3578")), on: state) {
            
            $0.elements = [.widget(.otp(3578))]
        }
    }
    
    func test_widget_otp_shouldSetOTPToFirstSixDigits() {
        
        let state = makeState(elements: [.widget(anyOTP())])
        
        assertState(.widget(.otp("abc3578_12345")), on: state) {
            
            $0.elements = [.widget(.otp(357812))]
        }
    }
    
    func test_widget_otp_shouldNotDeliverEffectOnNilOTP() {
        
        let state = makeState(elements: [.widget(anyOTP())])
        
        assert(.widget(.otp(anyNonDigitString())), on: state, effect: nil)
    }
    
    func test_widget_otp_shouldChangeStateOnOTP() {
        
        let state = makeState(elements: [.widget(anyOTP())])
        
        assertState(.widget(.otp("12345")), on: state) {
            
            $0.elements = [.widget(.otp(12345))]
        }
    }
    
    func test_widget_otp_shouldNotDeliverEffectOnOTP() {
        
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
        _ value: String = anyMessage()
    ) -> AnywayPaymentEvent.Widget {
        
        return .otp(value)
    }
    
    private func anyNonDigitString(
        from string: String = anyMessage()
    ) -> String {
        
        return string.filter { !$0.isNumber }
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
