//
//  PaymentProviderPickerFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

import PayHub
import XCTest

final class PaymentProviderPickerFlowReducerTests: PaymentProviderPickerFlowTests {
    
    // MARK: - dismiss
    
    func test_dismiss_shouldResetNavigationFromAlert() {
        
        assert(makeState(navigation: .alert(makeServiceFailure())), event: .dismiss) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffectOnAlert() {
        
        assert(makeState(navigation: .alert(makeServiceFailure())), event: .dismiss, delivers: nil)
    }
    
    func test_dismiss_shouldResetNavigationFromDestination() {
        
        assert(makeState(navigation: .destination(.payment(makePayment()))), event: .dismiss) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffectOnDestination() {
        
        assert(makeState(navigation: .destination(.payment(makePayment()))), event: .dismiss, delivers: nil)
    }
    
    func test_dismiss_shouldResetNavigationFromOutside() {
        
        assert(makeState(navigation: .outside(.back)), event: .dismiss) {
            
            $0.navigation = nil
        }
    }
    
    func test_dismiss_shouldNotDeliverEffectOnOutside() {
        
        assert(makeState(navigation: .outside(.back)), event: .dismiss, delivers: nil)
    }
    
    // MARK: - goToPayments
    
    func test_goToPayments_shouldSetNavigationToOutsidePayments() {
        
        assert(makeState(navigation: .alert(makeServiceFailure())), event: .goToPayments) {
            
            $0.navigation = .outside(.payments)
        }
    }
    
    func test_goToPayments_shouldNotDeliverEffect() {
        
        assert(makeState(navigation: .alert(makeServiceFailure())), event: .goToPayments, delivers: nil)
    }
    
    // MARK: - initiatePaymentResult
    
    func test_initiatePaymentResult_shouldSetAlertOnFailure() {
        
        let failure = makeServiceFailure()
        
        assert(makeState(), event: .initiatePaymentResult(.failure(failure))) {
            
            $0.navigation = .alert(failure)
        }
    }
    
    func test_initiatePaymentResult_shouldNotDeliverEffectOnFailure() {
        
        assert(makeState(), event: .initiatePaymentResult(.failure(makeServiceFailure())), delivers: nil)
    }
    
    func test_initiatePaymentResult_shouldSetPaymentDestinationOnSuccess() {
        
        let payment = makePayment()
        
        assert(makeState(), event: .initiatePaymentResult(.success(payment))) {
            
            $0.navigation = .destination(.payment(payment))
        }
    }
    
    func test_initiatePaymentResult_shouldNotDeliverEffectOnSuccess() {
        
        assert(makeState(), event: .initiatePaymentResult(.success(makePayment())), delivers: nil)
    }
    
    // MARK: - loadServices
    
    func test_loadServices_shouldSetDestinationOnServicePicker() {
        
        let picker = makeServicePicker()
        
        assert(makeState(), event: .loadServices(.servicePicker(picker))) {
            
            $0.navigation = .destination(.servicePicker(picker))
        }
    }
    
    func test_loadServices_shouldNotDeliverEffectOnServicePicker() {
        
        assert(makeState(), event: .loadServices(.servicePicker(makeServicePicker())), delivers: nil)
    }
    
    func test_loadServices_shouldSetServicesFailureDestinationOnServicesFailure() {
        
        let failure = makeServicesFailure()
        
        assert(makeState(), event: .loadServices(.servicesFailure(failure))) {
            
            $0.navigation = .destination(.servicesFailure(failure))
        }
    }
    
    func test_loadServices_shouldNotDeliverEffectOnServicesFailure() {
        
        assert(makeState(), event: .loadServices(.servicesFailure(makeServicesFailure())), delivers: nil)
    }
    
    // MARK: - payByInstructions
    
    func test_payByInstructions_shouldSetDestination() {
        
        let payByInstructions = makePayByInstructions()
        
        assert(makeState(), event: .payByInstructions(payByInstructions)) {
            
            $0.navigation = .destination(.payByInstructions(payByInstructions))
        }
    }
    
    func test_payByInstructions_shouldDeliverSelectLatestEffect() {
        
        assert(makeState(), event: .payByInstructions(makePayByInstructions()), delivers: nil)
    }
    
    // MARK: - select
    
    func test_select_latest_shouldSetStateToLoading() {
        
        assert(makeState(), event: .select(.latest(makeLatest()))) {
            
            $0.isLoading = true
        }
    }
    
    func test_select_latest_shouldDeliverSelectLatestEffect() {
        
        let latest = makeLatest()
        
        assert(makeState(), event: .select(.latest(latest)), delivers: .select(.latest(latest)))
    }
    
    func test_select_provider_shouldSetStateToLoading() {
        
        assert(makeState(), event: .select(.provider(makeProvider()))) {
            
            $0.isLoading = true
        }
    }
    
    func test_select_provider_shouldDeliverSelectProviderEffect() {
        
        let provider = makeProvider()
        
        assert(makeState(), event: .select(.provider(provider)), delivers: .select(.provider(provider)))
    }
    
    func test_select_chat_shouldSetStateChat() {
        
        assert(makeState(), event: .select(.chat)) {
            
            $0.navigation = .outside(.chat)
        }
    }
    
    func test_select_chat_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .select(.chat), delivers: nil)
    }
    
    func test_select_payByInstructions_shouldNotChangeState() {
        
        assert(makeState(), event: .select(.payByInstructions))
    }
    
    func test_select_payByInstructions_shouldDeliverEffect() {
        
        assert(makeState(), event: .select(.payByInstructions), delivers: .select(.payByInstructions))
    }
    
    func test_select_qr_shouldSetStateChat() {
        
        assert(makeState(), event: .select(.qr)) {
            
            $0.navigation = .outside(.qr)
        }
    }
    
    func test_select_qr_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .select(.qr), delivers: nil)
    }
    
    func test_select_back_shouldSetStateChat() {
        
        assert(makeState(), event: .select(.back)) {
            
            $0.navigation = .outside(.back)
        }
    }
    
    func test_select_back_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .select(.back), delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentProviderPickerFlowReducer<Latest, PayByInstructions, Payment, Provider, ServicePicker, ServicesFailure>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        isLoading: Bool = false,
        navigation: SUT.State.Navigation? = nil
    ) -> SUT.State {
        
        return .init(isLoading: isLoading, navigation: navigation)
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(String(describing: expectedState)), but got \(String(describing: receivedState)) instead.",
            file: file, line: line
        )
        
        return receivedState
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
