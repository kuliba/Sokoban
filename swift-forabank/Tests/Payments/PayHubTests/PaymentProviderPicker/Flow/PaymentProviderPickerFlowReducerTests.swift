//
//  PaymentProviderPickerFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

struct PaymentProviderPickerFlowState: Equatable {
    
    var isLoading: Bool
    
    init(
        isLoading: Bool = false
    ) {
        self.isLoading = isLoading
    }
}

// extension PaymentProviderPickerFlowState: Equatable {}

enum PaymentProviderPickerFlowEvent<Latest> {
    
    case select(Select)
}

extension PaymentProviderPickerFlowEvent {
    
    enum Select {
        
        case latest(Latest)
    }
}

extension PaymentProviderPickerFlowEvent: Equatable where Latest: Equatable {}
extension PaymentProviderPickerFlowEvent.Select: Equatable where Latest: Equatable {}

enum PaymentProviderPickerFlowEffect<Latest> {
    
    case select(Select)
}

extension PaymentProviderPickerFlowEffect {
    
    enum Select {
        
        case latest(Latest)
    }
}

extension PaymentProviderPickerFlowEffect: Equatable where Latest: Equatable {}
extension PaymentProviderPickerFlowEffect.Select: Equatable where Latest: Equatable {}

final class PaymentProviderPickerFlowReducer<Latest> {
    
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
    typealias Event = PaymentProviderPickerFlowEvent<Latest>
    typealias Effect = PaymentProviderPickerFlowEffect<Latest>
}

private extension PaymentProviderPickerFlowReducer {
    
    func select(
        _ state: inout State,
        _ effect: inout Effect?,
        with select: Event.Select
    ) {
        state.isLoading = true
        switch select {
        case let .latest(latest):
            effect = .select(.latest(latest))
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
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentProviderPickerFlowReducer<Latest>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
    ) -> SUT.State {
        
        return .init()
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
