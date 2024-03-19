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
        let effect = UtilityEffect.initiatePrepayment
        let (sut, _) = makeSUT(stub: (emptyFlow, effect))
        
        assert(sut: sut, .back, on: utilityFlowState, effect: nil)
    }
    
    func test_back_shouldDeliverEffectOnNonNilEffectFromUtilityFlowReduce() {
        
        let utilityFlowState = makeUtilityFlowState(.init())
        let nonEmptyFlow = makeSingleDestinationUtilityFlow()
        let effect = UtilityEffect.initiatePrepayment
        let (sut, _) = makeSUT(stub: (nonEmptyFlow, effect))
        
        assert(sut: sut, .back, on: utilityFlowState, effect: .utilityFlow(effect))
    }
    
    // MARK: - TapEvent: payByInstruction
    
    func test_tap_payByInstruction_shouldNotChangeNilRoute() {
        
        let nilRouteState = State(route: nil)
        
        assertState(.tap(.payByInstruction), on: nilRouteState)
    }
    
    func test_tap_payByInstruction_shouldNotDeliverEffectOnNilRoute() {
        
        let nilRouteState = State(route: nil)
        
        assert(.tap(.payByInstruction), on: nilRouteState, effect: nil)
    }
    
    func test_tap_payByInstruction_shouldPushPayByInstructionOnTopOfPrepaymentOptionsAsCurrentInUtilityFlow() {
        
        let prepaymentOptions = makePrepaymentOptions()
        let withOptionsState = makeUtilityFlowState(.init(stack: [prepaymentOptions]))
        
        assertState(.tap(.payByInstruction), on: withOptionsState) {
            
            $0.route = .utilityFlow(.init(stack: [
                prepaymentOptions,
                .payByInstruction
            ]))
        }
        XCTAssert(isCurrentPrepaymentOptions(withOptionsState))
    }
    
    func test_tap_payByInstruction_shouldNotDeliverEffectOnPrepaymentOptionsAsCurrentInUtilityFlow() {
        
        let prepaymentOptions = makePrepaymentOptions()
        let withOptionsState = makeUtilityFlowState(.init(stack: [prepaymentOptions]))

        assert(.tap(.payByInstruction), on: withOptionsState, effect: nil)
        XCTAssert(isCurrentPrepaymentOptions(withOptionsState))
    }

    func test_tap_payByInstruction_shouldReplacePrepaymentOptionsFailureAsCurrentInUtilityFlowWithPayByInstruction() {
        
        let prepaymentFailure = makeSingleDestinationUtilityFlow(.prepayment(.failure))
        let prepaymentFailureState = State(route: .utilityFlow(prepaymentFailure))

        assertState(.tap(.payByInstruction), on: prepaymentFailureState) {
            
            $0.route = .utilityFlow(.init(stack: [.payByInstruction]))
        }
        XCTAssert(isCurrentPrepaymentFailure(prepaymentFailureState))
    }
    
    func test_tap_payByInstruction_shouldNotDeliverEffectOnPrepaymentOptionsFailureAsCurrentInUtilityFlow() {
        
        let prepaymentFailure = makeSingleDestinationUtilityFlow(.prepayment(.failure))
        let prepaymentFailureState = State(route: .utilityFlow(prepaymentFailure))

        assert(.tap(.payByInstruction), on: prepaymentFailureState, effect: nil)
        XCTAssert(isCurrentPrepaymentFailure(prepaymentFailureState))
    }

    // MARK: - UtilityFlow: initiatePrepayment
    
    func test_utilityFlow_initiatePrepayment_shouldCallUtilityReduceWithEmptyFlowAndInitiateOnNilRoute() {
        
        let emptyFlow = UtilityFlow()
        let state = State(route: nil)
        let (sut, utilityReducerSpy) = makeSUT(stub: (.init(), nil))
        
        _ = sut.reduce(state, .utilityFlow(.initiatePrepayment))
        
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.state), [emptyFlow])
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.event), [.initiatePrepayment])
    }
    
    func test_utilityFlow_initiatePrepayment_shouldSetStateToUtilityFlowFromUtilityReduceOnNilRoute() {
        
        let state = State(route: nil)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, nil))
        
        assertState(sut: sut, .utilityFlow(.initiatePrepayment), on: state) {
            
            $0.route = .utilityFlow(newFlow)
        }
    }
    
    func test_utilityFlow_initiatePrepayment_shouldDeliverNilUtilityEffectFromUtilityReduceOnNilRoute() {
        
        let state = State(route: nil)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, nil))
        
        assert(sut: sut, .utilityFlow(.initiatePrepayment), on: state, effect: nil)
    }
    
    func test_utilityFlow_initiatePrepayment_shouldDeliverNonNilUtilityEffectFromUtilityReduceOnNilRoute() {
        
        let state = State(route: nil)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, .initiatePrepayment))
        
        assert(sut: sut, .utilityFlow(.initiatePrepayment), on: state, effect: .utilityFlow(.initiatePrepayment))
    }
    
    func test_utilityFlow_initiatePrepayment_shouldCallUtilityReduceWithFlowAndInitiateOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let (sut, utilityReducerSpy) = makeSUT(stub: (.init(), nil))
        
        _ = sut.reduce(state, .utilityFlow(.initiatePrepayment))
        
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.state), [flow])
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.event), [.initiatePrepayment])
    }
    
    func test_utilityFlow_initiatePrepayment_shouldSetStateToUtilityFlowFromUtilityReduceOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, nil))
        
        assertState(sut: sut, .utilityFlow(.initiatePrepayment), on: state) {
            
            $0.route = .utilityFlow(newFlow)
        }
    }
    
    func test_utilityFlow_initiatePrepayment_shouldDeliverNilUtilityEffectFromUtilityReduceOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, nil))
        
        assert(sut: sut, .utilityFlow(.initiatePrepayment), on: state, effect: nil)
    }
    
    func test_utilityFlow_initiatePrepayment_shouldDeliverNonNilUtilityEffectFromUtilityReduceOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, .initiatePrepayment))
        
        assert(sut: sut, .utilityFlow(.initiatePrepayment), on: state, effect: .utilityFlow(.initiatePrepayment))
    }
    
    // MARK: - UtilityFlow: prepaymentLoaded
    
    func test_utilityFlow_prepaymentLoaded_shouldNotCallUtilityReduceWithFlowAndEventOnNilRoute() {
        
        let nilRouteState = State(route: nil)
        let event = UtilityEvent.prepaymentLoaded(.failure)
        let (sut, utilityReducerSpy) = makeSUT(stub: (.init(), nil))
        
        _ = sut.reduce(nilRouteState, .utilityFlow(event))
        
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.state), [])
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.event), [])
    }
    
    func test_utilityFlow_prepaymentLoaded_shouldNotChangeStateToUtilityFlowFromUtilityReduceOnNilRoute() {
        
        let nilRouteState = State(route: nil)
        let event = UtilityEvent.prepaymentLoaded(.failure)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, nil))
        
        assertState(sut: sut, .utilityFlow(event), on: nilRouteState)
    }
    
    func test_utilityFlow_prepaymentLoaded_shouldNotDeliverUtilityEffectFromUtilityReduceOnNilRoute() {
        
        let nilRouteState = State(route: nil)
        let event = UtilityEvent.prepaymentLoaded(.failure)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, .initiatePrepayment))
        
        assert(sut: sut, .utilityFlow(event), on: nilRouteState, effect: nil)
    }
    
    func test_utilityFlow_prepaymentLoaded_shouldCallUtilityReduceWithFlowAndEventOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let event = UtilityEvent.prepaymentLoaded(.failure)
        let (sut, utilityReducerSpy) = makeSUT(stub: (.init(), nil))
        
        _ = sut.reduce(state, .utilityFlow(event))
        
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.state), [flow])
        XCTAssertNoDiff(utilityReducerSpy.messages.map(\.event), [event])
    }
    
    func test_utilityFlow_prepaymentLoaded_shouldChangeStateToUtilityFlowFromUtilityReduceOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let event = UtilityEvent.prepaymentLoaded(.failure)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, nil))
        
        assertState(sut: sut, .utilityFlow(event), on: state) {
            
            $0.route = .utilityFlow(newFlow)
        }
    }
    
    func test_utilityFlow_prepaymentLoaded_shouldDeliverUtilityEffectFromUtilityReduceOnNonNilRoute() {
        
        let flow = makeEmptyUtilityFlow()
        let state = State(route: .utilityFlow(flow))
        let event = UtilityEvent.prepaymentLoaded(.failure)
        let newFlow = makeSingleDestinationUtilityFlow()
        let (sut, _) = makeSUT(stub: (newFlow, .initiatePrepayment))
        
        assert(sut: sut, .utilityFlow(event), on: state, effect: .utilityFlow(.initiatePrepayment))
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
    
    private func isCurrentPrepaymentOptions(
        _ state: State
    ) -> Bool {
        
        switch state.route {
        case let .utilityFlow(utilityFlow):
            if case .prepayment(.options) = utilityFlow.current {
                return true
            } else {
                return false
            }
            
        default:
            return false
        }
    }
    
    private func isCurrentPrepaymentFailure(
        _ state: State
    ) -> Bool {
        
        switch state.route {
        case let .utilityFlow(utilityFlow):
            if case .prepayment(.failure) = utilityFlow.current {
                return true
            } else {
                return false
            }
            
        default:
            return false
        }
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
