//
//  PayHubFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

struct PayHubFlowState<Exchange, Latest, Status, Templates> {
    
    var isLoading = false
    var selected: PayHubFlowItem<Exchange, Latest, Templates>?
    var status: Status?
}

extension PayHubFlowState: Equatable where Exchange: Equatable, Latest: Equatable, Status: Equatable, Templates: Equatable {}

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
                state.selected = .none
            }
            
        case let .flowEvent(flowEvent):
            break
            
        case let .selected(selected):
            state.selected = selected
        }
        
        return (state, effect)
    }
}

extension PayHubFlowReducer {
    
    typealias State = PayHubFlowState<Exchange, LatestFlow, Status, Templates>
    typealias Event = PayHubFlowEvent<Exchange, Latest, LatestFlow, Status, Templates>
    typealias Effect = PayHubFlowEffect<Latest>
}

import PayHub
import XCTest

final class PayHubFlowReducerTests: PayHubFlowTests {
    
    // MARK: - flowEvent
    
    func test_flowEvent_shouldSetIsLoadingToFalseAndStatusToNil() {
        
        let state = makeState(isLoading: true, status: makeStatus())
        let event = makeFlowEvent(false, nil)
        
        assert(state, event: event) {
            
            $0.isLoading = false
            $0.status = nil
        }
    }
    
    func test_flowEvent_shouldNotDeliverEffectOnNilStateIsLoadingFalseNilStatus() {
        
        let state = makeState(isLoading: true, status: makeStatus())
        let event = makeFlowEvent(false, nil)

        assert(state, event: event, delivers: nil)
    }
    
    func test_flowEvent_shouldSetIsLoadingToTrueAndStatusToNil() {
        
        let state = makeState(isLoading: false, status: makeStatus())
        let event = makeFlowEvent(true, nil)
        
        assert(state, event: event) {
            
            $0.isLoading = true
            $0.status = nil
        }
    }
    
    func test_flowEvent_shouldNotDeliverEffectOnNilStateIsLoadingTrueNilStatus() {
        
        let state = makeState(isLoading: false, status: makeStatus())
        let event = makeFlowEvent(true, nil)

        assert(state, event: event, delivers: nil)
    }
    
    
    //    func test_flowEvent_shouldNotDeliverEffectOnNilStateIsLoadingTrueNilStatus() {
    //
    //        let flowEvent = makeFlowEvent(true, nil)
    //
    //        assert(nil, event: flowEvent, delivers: nil)
    //    }
    //
    //    func test_flowEvent_() {
    //
    //        let flowEvent = makeFlowEvent(false, makeStatus())
    //    }
    //
    //    func test_flowEvent_shouldNotDeliverEffectOnNilStateIsLoadingFalseNonNilStatus() {
    //
    //        let flowEvent = makeFlowEvent(false, makeStatus())
    //
    //        assert(nil, event: flowEvent, delivers: nil)
    //    }
    //
    //    func test_flowEvent_2() {
    //
    //        let flowEvent = makeFlowEvent(true, makeStatus())
    //    }
    //
    //    func test_flowEvent_shouldNotDeliverEffectOnNilStateIsLoadingTrueNonNilStatus() {
    //
    //        let flowEvent = makeFlowEvent(true, makeStatus())
    //
    //        assert(nil, event: flowEvent, delivers: nil)
    //    }
    
    // MARK: - select
    
    func test_select_shouldResetStateOnSelectNil() {
        
        let state = makeState(selected: .exchange(makeExchangeFlowNode()))
        
        assert(state, event: .select(nil)) {
            
            $0.selected = .none
        }
    }
    
    func test_select_shouldNotDeliverEffectOnSelectNil() {
        
        let state = makeState(selected: .exchange(makeExchangeFlowNode()))

        assert(state, event: .select(nil), delivers: nil)
    }
    
    func test_select_shouldNotChangeStateOnSelectExchange() {
        
        let state = makeState(selected: nil)

        assert(state, event: .select(.exchange))
    }
    
    func test_select_shouldDeliverEffectOnSelectExchange() {
        
        assert(makeState(selected: nil), event: .select(.exchange), delivers: .select(.exchange))
    }
    
    func test_select_shouldDeliverEffectOnSelectLatest() {
        
        let latest = makeLatest()
        
        assert(makeState(selected: nil), event: .select(.latest(latest)), delivers: .select(.latest(latest)))
    }
    
    func test_select_shouldDeliverEffectOnSelectTemplates() {
        
        assert(makeState(selected: nil), event: .select(.templates), delivers: .select(.templates))
    }
    
    // MARK: - selected
    
    func test_selected_shouldSetSelectedToExchangeOnExchange() {
        
        let exchange = makeExchangeFlowNode()
        
        assert(makeState(selected: nil), event: .selected(.exchange(exchange))) {
            
            $0.selected = .exchange(exchange)
        }
    }
    
    func test_selected_shouldSetSelectedToLatestOnLatest() {
        
        let latest = makeLatestFlowNode()
        
        assert(makeState(selected: nil), event: .selected(.latest(latest))) {
            
            $0.selected = .latest(latest)
        }
    }
    
    func test_selected_shouldSetSelectedToTemplatesOnTemplates() {
        
        let templates = makeTemplatesFlowNode()
        
        assert(makeState(selected: nil), event: .selected(.templates(templates))) {
            
            $0.selected = .templates(templates)
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
    
    private func makeState(
        isLoading: Bool = false,
        selected: PayHubFlowItem<Exchange, LatestFlow, Templates>? = nil,
        status: Status? = nil
    ) -> SUT.State {
        
        return .init(
            isLoading: isLoading,
            selected: selected,
            status: status
        )
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
            receivedState.equatableProjection,
            expectedState.equatableProjection,
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
