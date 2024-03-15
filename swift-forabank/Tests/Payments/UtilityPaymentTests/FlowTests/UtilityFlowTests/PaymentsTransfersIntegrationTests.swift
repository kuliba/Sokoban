//
//  PaymentsTransfersIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

struct PaymentsTransfersState<UtilityDestination> {
    
    var route: Route?
}

extension PaymentsTransfersState {
    
    enum Route {
        
        case utilityFlow(UtilityFlow)
    }
}

extension PaymentsTransfersState.Route {
    
    typealias UtilityFlow = Flow<UtilityDestination>
}

extension PaymentsTransfersState: Equatable where UtilityDestination: Equatable {}
extension PaymentsTransfersState.Route: Equatable where UtilityDestination: Equatable {}

enum PaymentsTransfersEvent: Equatable {
    
    case back
}

enum PaymentsTransfersEffect {
    
    case utilityFlow(UtilityFlow)
}

extension PaymentsTransfersEffect {
    
    typealias UtilityFlow = UtilityFlowEffect
}

extension PaymentsTransfersEffect: Equatable {}

final class PaymentsTransfersReducer<LastPayment, Operator> {
    
    private let utilityReduce: UtilityReduce
    
    init(utilityReduce: @escaping UtilityReduce) {
        
        self.utilityReduce = utilityReduce
    }
}

extension PaymentsTransfersReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .back:
            (state, effect) = back(state)
        }
        
        return (state, effect)
    }
}

extension PaymentsTransfersReducer {
    
    typealias UtilityReduce = (UtilityState, UtilityEvent) -> (UtilityState, UtilityEffect?)
    
    typealias UtilityState = Flow<Destination>
    typealias UtilityEvent = UtilityFlowEvent<LastPayment, Operator>
    typealias UtilityEffect = UtilityFlowEffect
    
    typealias Destination = UtilityDestination<LastPayment, Operator>
    
    typealias State = PaymentsTransfersState<Destination>
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}

private extension PaymentsTransfersReducer {
    
    func back(
        _ state: State
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch state.route {
        case .none:
            break
            
        case let .utilityFlow(utilityFlow):
            let (s, e) = utilityReduce(utilityFlow, .back)
            if s.isEmpty {
                state.route = nil
            } else {
                state.route = .utilityFlow(s)
                effect = e.map { .utilityFlow($0) }
            }
        }
        
        return (state, effect)
    }
}

private extension Flow {
    
    var isEmpty: Bool { stack.isEmpty }
}

final class PaymentsTransfersEffectHandler {}

extension PaymentsTransfersEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError()
    }
}

extension PaymentsTransfersEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = PaymentsTransfersState
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}

final class PaymentsTransfersReducerTests: XCTestCase {
    
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
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersReducer<LastPayment, Operator>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias Destination = UtilityDestination<LastPayment, Operator>
    
    private typealias UtilityReducerSpy = ReducerSpy<UtilityFlow, UtilityEvent, UtilityFlowEffect>
    private typealias UtilityState = Flow<Destination>
    private typealias UtilityEvent = UtilityFlowEvent<LastPayment, Operator>
    private typealias UtilityEffect = UtilityFlowEffect
    
    private typealias UtilityReduceStub = (UtilityState, UtilityEffect?)
    
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
        let sut = sut ?? makeSUT(stub: (UtilityState(), nil)).sut
        
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

final class PaymentsTransfersIntegrationTests: XCTestCase {
    
    // MARK: - back
    
    func test_back______() {
        
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    
    private typealias Reducer = PaymentsTransfersReducer<LastPayment, Operator>
    private typealias UtilityReducer = UtilityFlowReducer<LastPayment, Operator>
    
    private typealias Destination = UtilityDestination<LastPayment, Operator>
    
    private typealias StateSpy = ValueSpy<State>
    
    private typealias State = PaymentsTransfersState<Destination>
    private typealias Event = PaymentsTransfersEvent
    private typealias Effect = PaymentsTransfersEffect
    
    private func makeSUT(
        initialRoute: State.Route? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy
    ) {
        let utilityReducer = UtilityReducer()
        let reducer = Reducer(
            utilityReduce: utilityReducer.reduce(_:_:)
        )
        
        let effectHandler = PaymentsTransfersEffectHandler()
        
        let sut = SUT(
            initialState: .init(route: initialRoute),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
        
        let spy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(reducer, file: file, line: line)
        trackForMemoryLeaks(effectHandler, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func assert(
        _ spy: StateSpy,
        _ initialState: State,
        _ updates: ((inout State) -> Void)...,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var state = initialState
        var values = [State]()
        
        for update in updates {
            
            update(&state)
            values.append(state)
        }
        
        XCTAssertNoDiff(spy.values, values, file: file, line: line)
    }
}

private typealias UtilityFlow = Flow<Destination>
private typealias Destination = UtilityDestination<LastPayment, Operator>

// while `operators` is Array (not NonEmptyArray) only
private func makePrepaymentEmptyOptions(
) -> Destination {
    
    .prepayment(.options(.init()))
}

private func makePrepaymentOptions(
    lastPayments: [LastPayment] = [],
    operators: [Operator] = [makeOperator()],
    searchText: String = ""
) -> Destination {
    
    .prepayment(.options(.init(
        lastPayments: lastPayments,
        operators: operators,
        searchText: searchText
    )))
}

private func makeEmptyUtilityFlow(
    file: StaticString = #file,
    line: UInt = #line
) -> UtilityFlow {
    
    let flow = UtilityFlow.init(stack: .init([]))
    
    XCTAssert(flow.stack.isEmpty)
    
    return flow
}

private func makeSingleDestinationUtilityFlow(
    _ destination: Destination? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> UtilityFlow {
    
    let flow = UtilityFlow.init(stack: .init([
        destination ?? .services
    ]))
    
    XCTAssertNoDiff(flow.stack.count, 1)
    
    return flow
}

private func makeUtilityFlowState(
    _ flow: UtilityFlow
) -> PaymentsTransfersState<Destination> {
    
    .init(route: .utilityFlow(flow))
}
