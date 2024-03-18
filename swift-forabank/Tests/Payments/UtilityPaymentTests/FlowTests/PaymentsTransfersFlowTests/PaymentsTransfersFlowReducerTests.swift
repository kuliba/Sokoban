//
//  PaymentsTransfersFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment
import XCTest

final class PaymentsTransfersFlowReducerTests: XCTestCase {
    
    // MARK: - back
    
    func test_back_shouldNotChangeNilRouteState() {
        
        let nilRouteState = State(route: nil)
        
        assertState(.back, on: nilRouteState)
    }
    
    func test_back_shouldNotDeliverEffectOnNilRouteState() {
        
        let nilRouteState = State(route: nil)
        
        assert(.back, on: nilRouteState, effect: nil)
    }
    
    func test_back_shouldChangeRouteToNilOnEmptyUtilityFlowState() {
        
        let emptyUtilityFlowState = makeUtilityFlowState(makeEmptyUtilityFlow())
        
        assertState(.back, on: emptyUtilityFlowState) {
            
            $0.route = nil
        }
    }
    
    func test_back_shouldNotDeliverEffectOnEmptyUtilityFlowState() {
        
        let emptyUtilityFlowState = makeUtilityFlowState(makeEmptyUtilityFlow())
        
        assert(.back, on: emptyUtilityFlowState, effect: nil)
    }
    
    func test_back_shouldChangeUtilityFlowStateToNilOnEmptyFlowFromUtilityFlowReduce() {
        
        let utilityFlowState = makeUtilityFlowState(.init())
        let emptyFlow = UtilityFlow()
        let (sut, _) = makeSUT(stub: (emptyFlow, nil))
        
        assertState(sut: sut, .back, on: utilityFlowState) {
            
            $0.route = nil
        }
    }
    
    func test_back_shouldChangeUtilityFlowStateOnNonEmptyFlowFromUtilityFlowReduce() {
        
        let utilityFlowState = makeUtilityFlowState(.init())
        let nonEmptyFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (nonEmptyFlow, nil))
        
        assertState(sut: sut, .back, on: utilityFlowState) {
            
            $0.route = .utilityFlow(nonEmptyFlow)
        }
    }
    
    func test_back_shouldNotDeliverEffectOnNilEffectFromUtilityFlowReduce() {
        
        let utilityFlowState = makeUtilityFlowState(.init())
        let (sut, _) = makeSUT(stub: (.init(), nil))
        
        assert(sut: sut, .back, on: utilityFlowState, effect: nil)
    }
    
    func test_back_shouldNotDeliverEffectOnEmptyFlowAndNonNilEffectFromUtilityFlowReduce() {
        
        let utilityFlowState = makeUtilityFlowState(.init())
        let emptyFlow = UtilityFlow()
        let effect = UtilityEffect.initiate
        let (sut, _) = makeSUT(stub: (emptyFlow, effect))
        
        assert(sut: sut, .back, on: utilityFlowState, effect: nil)
    }
    
    func test_back_shouldDeliverEffectOnNonNilEffectFromUtilityFlowReduce() {
        
        let utilityFlowState = makeUtilityFlowState(.init())
        let nonEmptyFlow = makeSingleDestinationUtilityFlow()
        let effect = UtilityEffect.initiate
        let (sut, _) = makeSUT(stub: (nonEmptyFlow, effect))
        
        assert(sut: sut, .back, on: utilityFlowState, effect: .utilityFlow(effect))
    }
    
    // MARK: - initiate utilityFlow
    
    func test_utilityFlow_initiate_shouldCallUtilityReduceWithEmptyFlowAndInitiateOnNilRoute() {
        
        let emptyFlow = UtilityFlow()
        let state = State(route: nil)
        let (sut, utilityReducerSpy) = makeSUT(stub: (.init(), nil))
        
        _ = sut.reduce(state, .utilityFlow(.initiate))
        
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.state), [emptyFlow])
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.event), [.initiate])
    }
    
    func test_utilityFlow_initiate_shouldSetStateToUtilityFlowFromUtilityReduceOnNilRoute() {
        
        let state = State(route: nil)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, nil))
        
        assertState(sut: sut, .utilityFlow(.initiate), on: state) {
            
            $0.route = .utilityFlow(newFlow)
        }
    }
    
    func test_utilityFlow_initiate_shouldDeliverNilUtilityEffectFromUtilityReduceOnNilRoute() {
        
        let state = State(route: nil)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, nil))
        
        assert(sut: sut, .utilityFlow(.initiate), on: state, effect: nil)
    }
    
    func test_utilityFlow_initiate_shouldDeliverNonNilUtilityEffectFromUtilityReduceOnNilRoute() {
        
        let state = State(route: nil)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, .initiate))
        
        assert(sut: sut, .utilityFlow(.initiate), on: state, effect: .utilityFlow(.initiate))
    }
    
    func test_utilityFlow_initiate_shouldCallUtilityReduceWithFlowAndInitiateOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let (sut, utilityReducerSpy) = makeSUT(stub: (.init(), nil))
        
        _ = sut.reduce(state, .utilityFlow(.initiate))
        
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.state), [flow])
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.event), [.initiate])
    }
    
    func test_utilityFlow_initiate_shouldSetStateToUtilityFlowFromUtilityReduceOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, nil))
        
        assertState(sut: sut, .utilityFlow(.initiate), on: state) {
            
            $0.route = .utilityFlow(newFlow)
        }
    }
    
    func test_utilityFlow_initiate_shouldDeliverNilUtilityEffectFromUtilityReduceOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, nil))
        
        assert(sut: sut, .utilityFlow(.initiate), on: state, effect: nil)
    }
    
    func test_utilityFlow_initiate_shouldDeliverNonNilUtilityEffectFromUtilityReduceOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, .initiate))
        
        assert(sut: sut, .utilityFlow(.initiate), on: state, effect: .utilityFlow(.initiate))
    }
    
    // MARK: - loaded
    
    func test_utilityFlow_loaded_shouldNotCallUtilityReduceWithFlowAndEventOnNilRoute() {
        
        let nilRouteState = State(route: nil)
        let event = UtilityEvent.loaded(.failure)
        let (sut, utilityReducerSpy) = makeSUT(stub: (.init(), nil))
        
        _ = sut.reduce(nilRouteState, .utilityFlow(event))
        
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.state), [])
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.event), [])
    }
    
    func test_utilityFlow_loaded_shouldNotChangeStateToUtilityFlowFromUtilityReduceOnNilRoute() {
        
        let nilRouteState = State(route: nil)
        let event = UtilityEvent.loaded(.failure)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, nil))
        
        assertState(sut: sut, .utilityFlow(event), on: nilRouteState)
    }
    
    func test_utilityFlow_loaded_shouldNotDeliverUtilityEffectFromUtilityReduceOnNilRoute() {
        
        let nilRouteState = State(route: nil)
        let event = UtilityEvent.loaded(.failure)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, .initiate))
        
        assert(sut: sut, .utilityFlow(event), on: nilRouteState, effect: nil)
    }
    
    func test_utilityFlow_loaded_shouldCallUtilityReduceWithFlowAndEventOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let event = UtilityEvent.loaded(.failure)
        let (sut, utilityReducerSpy) = makeSUT(stub: (.init(), nil))
        
        _ = sut.reduce(state, .utilityFlow(event))
        
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.state), [flow])
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.event), [event])
    }
    
    func test_utilityFlow_loaded_shouldChangeStateToUtilityFlowFromUtilityReduceOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let event = UtilityEvent.loaded(.failure)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, nil))
        
        assertState(sut: sut, .utilityFlow(event), on: state) {
            
            $0.route = .utilityFlow(newFlow)
        }
    }
    
    func test_utilityFlow_loaded_shouldDeliverUtilityEffectFromUtilityReduceOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let event = UtilityEvent.loaded(.failure)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, .initiate))
        
        assert(sut: sut, .utilityFlow(event), on: state, effect: .utilityFlow(.initiate))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersFlowReducer<LastPayment, Operator, Service, StartPaymentResponse>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
        
    private typealias UtilityReducerSpy = ReducerSpy<UtilityFlow, UtilityEvent, UtilityEffect>
    
    private typealias UtilityReduceStub = (UtilityFlow, UtilityEffect?)
    
    private func makeSUT(
        stub: UtilityReduceStub,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        utilityReducerSpy: UtilityReducerSpy
    ) {
        let utilityReducerSpy = UtilityReducerSpy(stub: [stub])
        
        let sut = SUT(utilityReduce: utilityReducerSpy.reduce(_:_:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(utilityReducerSpy, file: file, line: line)
        
        return (sut, utilityReducerSpy)
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
        let sut = sut ?? makeSUT(stub: (UtilityFlow(), nil)).sut
        
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
        let sut = sut ?? makeSUT(stub: (UtilityFlow(), nil)).sut
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
