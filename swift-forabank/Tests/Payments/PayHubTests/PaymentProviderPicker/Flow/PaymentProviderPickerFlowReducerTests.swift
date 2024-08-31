//
//  PaymentProviderPickerFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

struct PaymentProviderPickerFlowState: Equatable {
    
    var isLoading: Bool
    var navigation: Navigation?
}

 extension PaymentProviderPickerFlowState {
     
     enum Navigation: Equatable {
         
         case back, chat, qr
     }
 }
// extension PaymentProviderPickerFlowState: Equatable {}

enum PaymentProviderPickerFlowEvent<Latest, Provider> {
    
    case select(Select)
}

extension PaymentProviderPickerFlowEvent {
    
    enum Select {
        
        case back
        case chat
        case latest(Latest)
        case payByInstructions
        case provider(Provider)
        case qr
    }
}

extension PaymentProviderPickerFlowEvent: Equatable where Latest: Equatable, Provider: Equatable {}
extension PaymentProviderPickerFlowEvent.Select: Equatable where Latest: Equatable, Provider: Equatable {}

enum PaymentProviderPickerFlowEffect<Latest, Provider> {
    
    case select(Select)
}

extension PaymentProviderPickerFlowEffect {
    
    enum Select {
        
        case latest(Latest)
        case payByInstructions
        case provider(Provider)
    }
}

extension PaymentProviderPickerFlowEffect: Equatable where Latest: Equatable, Provider: Equatable {}
extension PaymentProviderPickerFlowEffect.Select: Equatable where Latest: Equatable, Provider: Equatable {}

final class PaymentProviderPickerFlowReducer<Latest, Provider> {
    
    init() {}
}

extension PaymentProviderPickerFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .select(select):
            self.select(&state, &effect, with: select)
        }
        
        return (state, effect)
    }
}

extension PaymentProviderPickerFlowReducer {
    
    typealias State = PaymentProviderPickerFlowState
    typealias Event = PaymentProviderPickerFlowEvent<Latest, Provider>
    typealias Effect = PaymentProviderPickerFlowEffect<Latest, Provider>
}

private extension PaymentProviderPickerFlowReducer {
    
    func select(
        _ state: inout State,
        _ effect: inout Effect?,
        with select: Event.Select
    ) {
        switch select {
        case .back:
            state.navigation = .back
            
        case .chat:
            state.navigation = .chat
            
        case let .latest(latest):
            state.isLoading = true
            effect = .select(.latest(latest))
            
        case .payByInstructions:
            effect = .select(.payByInstructions)
            
        case let .provider(provider):
            state.isLoading = true
            effect = .select(.provider(provider))
            
        case .qr:
            state.navigation = .qr
        }
    }
}

import XCTest

final class PaymentProviderPickerFlowReducerTests: PaymentProviderPickerFlowTests {
    
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
            
            $0.navigation = .chat
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
            
            $0.navigation = .qr
        }
    }
    
    func test_select_qr_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .select(.qr), delivers: nil)
    }
    
    func test_select_back_shouldSetStateChat() {
        
        assert(makeState(), event: .select(.back)) {
            
            $0.navigation = .back
        }
    }
    
    func test_select_back_shouldNotDeliverEffect() {
        
        assert(makeState(), event: .select(.back), delivers: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentProviderPickerFlowReducer<Latest, Provider>
    
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
