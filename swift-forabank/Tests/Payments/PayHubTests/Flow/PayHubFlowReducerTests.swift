//
//  PayHubFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

typealias PayHubFlowState<Exchange, Latest, Templates> = Optional<PayHubFlowItem<Exchange, Latest, Templates>>

final class PayHubFlowReducer<Exchange, Latest, LatestFlow, Status, Templates> {}

extension PayHubFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .select(select):
            if let select {
                effect = .select(select)
            } else {
                state = .none
            }
            
        case let .flowEvent(flowEvent):
            break
            
        case let .selected(selected):
            state = selected
        }
        
        return (state, effect)
    }
}

extension PayHubFlowReducer {
    
    typealias State = PayHubFlowState<Exchange, LatestFlow, Templates>
    typealias Event = PayHubFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>
    typealias Effect = PayHubFlowEffect<Latest>
}

import PayHub
import XCTest

final class PayHubFlowReducerTests: PayHubFlowTests {
    
    // MARK: - select
    
    func test_select_shouldResetStateOnSelectNil() {
        
        assert(.exchange(makeExchangeFlowNode()), event: .select(nil)) {
            
            $0 = .none
        }
    }
    
    func test_select_shouldNotDeliverEffectOnSelectNil() {
        
        assert(.exchange(makeExchangeFlowNode()), event: .select(nil), delivers: nil)
    }
    
    func test_select_shouldNotChangeStateOnSelectExchange() {
        
        assert(.none, event: .select(.exchange))
    }
    
    func test_select_shouldDeliverEffectOnSelectExchange() {
        
        assert(.none, event: .select(.exchange), delivers: .select(.exchange))
    }
    
    func test_select_shouldDeliverEffectOnSelectLatest() {
        
        let latest = makeLatest()
        
        assert(.none, event: .select(.latest(latest)), delivers: .select(.latest(latest)))
    }
    
    func test_select_shouldDeliverEffectOnSelectTemplates() {
        
        assert(.none, event: .select(.templates), delivers: .select(.templates))
    }
    
    // MARK: - selected
    
    func test_selected_shouldSetSelectedToExchangeOnExchange() {
        
        let exchange = makeExchangeFlowNode()
        
        assert(.none, event: .selected(.exchange(exchange))) {
            
            $0 = .exchange(exchange)
        }
    }
    
    func test_selected_shouldSetSelectedToLatestOnLatest() {
        
        let latest = makeLatestFlowNode()
        
        assert(.none, event: .selected(.latest(latest))) {
            
            $0 = .latest(latest)
        }
    }
    
    func test_selected_shouldSetSelectedToTemplatesOnTemplates() {
        
        let templates = makeTemplatesFlowNode()
        
        assert(.none, event: .selected(.templates(templates))) {
            
            $0 = .templates(templates)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PayHubFlowReducer<Exchange, Latest, LatestFlow, Status, Templates>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeFlowEvent(
        _ isLoading: Bool,
        _ status: Status? = nil
    ) -> SUT.Event {
        
        SUT.Event.flowEvent(.init(isLoading: isLoading, status: status))
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
            receivedState?.equatableProjection,
            expectedState?.equatableProjection,
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
