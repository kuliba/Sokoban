//
//  UtilityFlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

enum UtilityFlowEvent<LastPayment, Operator> {
    
    case back
    case initiate
    case loaded(Loaded)
}

extension UtilityFlowEvent {
    
    enum Loaded {
        
        case failure
        case success([LastPayment], [Operator])
    }
}

extension UtilityFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}

extension UtilityFlowEvent.Loaded: Equatable where LastPayment: Equatable, Operator: Equatable {}

enum UtilityFlowEffect {
    
    case initiate
}

extension UtilityFlowEffect: Equatable {}

final class UtilityFlowReducer<LastPayment, Operator> {
    
}

extension UtilityFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .back:
            state.current = nil
            
        case .initiate:
            if state.current == nil {
                effect = .initiate
            }
            
        case let .loaded(loaded):
            if state.current == nil {
                
                switch loaded {
                case .failure:
                    state.current = .prepayment(.failure)
                    
                case let .success(lastPayments, operators):
                    state.push(.prepayment(.options(.init(
                        lastPayments: lastPayments,
                        operators: operators
                    ))))
                }
            }
        }
        
        return (state, effect)
    }
}

extension UtilityFlowReducer {
    
    typealias Destination = UtilityDestination<LastPayment, Operator>
    
    typealias State = Flow<Destination>
    typealias Event = UtilityFlowEvent<LastPayment, Operator>
    typealias Effect = UtilityFlowEffect
}

final class UtilityFlowReducerTests: XCTestCase {
    
    // MARK: - back
    
    func test_back_shouldNotChangeEmptyState() {
        
        let emptyState = State()
        
        assertState(.back, on: emptyState)
    }
    
    func test_back_shouldNotDeliverEffectOnEmptyState() {
        
        let emptyState = State()
        
        assert(.back, on: emptyState, effect: nil)
    }
    
    func test_back_shouldChangeStateToEmptyOnSingleFlowState() {
        
        let singleFlow = State(stack: .init(.services))
        
        assertState(.back, on: singleFlow) {
            
            $0 = .init()
        }
    }
    
    func test_back_shouldNotDeliverEffectOnSingleFlowState() {
        
        let singleFlow = State(stack: .init(.services))
        
        assert(.back, on: singleFlow, effect: nil)
    }
    
    func test_back_shouldRemoveTopOnMultiFlowState() {
        
        let multiFlowState = State(stack: .init(.services, .prepayment(.failure)))
        
        assertState(.back, on: multiFlowState) {
            
            $0 = .init(stack: .init(.services))
        }
    }
    
    func test_back_shouldNotDeliverEffectOnMultiFlowState() {
        
        let multiFlowState = State(stack: .init(.services, .prepayment(.failure)))
        
        assert(.back, on: multiFlowState, effect: nil)
    }
    
    // MARK: - initiate
    
    func test_initiate_shouldNotChangeEmptyState() {
        
        let emptyState = State()
        
        assertState(.initiate, on: emptyState)
    }
    
    func test_initiate_shouldDeliverEffectOnEmptyState() {
        
        let emptyState = State()
        
        assert(.initiate, on: emptyState, effect: .initiate)
    }
    
    func test_initiate_shouldNotChangeNonEmptyState() {
        
        let nonEmptyState = State(stack: .init(.services))
        
        assertState(.initiate, on: nonEmptyState)
    }
    
    func test_initiate_shouldNotDeliverEffectOnNonEmptyState() {
        
        let nonEmptyState = State(stack: .init(.services))
        
        assert(.initiate, on: nonEmptyState, effect: nil)
    }
    
    // MARK: - loaded
    
    func test_loaded_shouldChangeStateToFailureOnLoadFailureOnEmptyState() {
        
        let emptyState = State()
        
        assertState(.loaded(.failure), on: emptyState) {
            
            $0.push(.prepayment(.failure))
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadFailureOnEmptyState() {
        
        let emptyState = State()
        
        assert(.loaded(.failure), on: emptyState, effect: nil)
    }
    
    func test_loaded_shouldNotChangeStateOnLoadFailureOnNonEmptyState() {
        
        let nonEmptyState = State(stack: .init(.services))
        
        assertState(.loaded(.failure), on: nonEmptyState)
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadFailureOnNonEmptyState() {
        
        let nonEmptyState = State(stack: .init(.services))
        
        assert(.loaded(.failure), on: nonEmptyState, effect: nil)
    }
    
    func test_loaded_shouldChangeEmptyStateOnLoadSuccess_emptyLastPayments() {
        
        let operators = [makeOperator()]
        let emptyState = State()
        
        assertState(.loaded(.success([], operators)), on: emptyState) {
            
            $0.push(.prepayment(.options(.init(
                lastPayments: [],
                operators: operators
            ))))
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadSuccessOnEmptyState_emptyLastPayments() {
        
        let operators = [makeOperator()]
        let emptyState = State()
        
        assert(.loaded(.success([], operators)), on: emptyState, effect: nil)
    }
    
    func test_loaded_shouldChangeEmptyStateOnLoadSuccess_nonEmptyLastPayments() {
        
        let lastPayments = [makeLastPayment()]
        let operators = [makeOperator()]
        let emptyState = State()
        
        assertState(.loaded(.success(lastPayments, operators)), on: emptyState) {
            
            $0.push(.prepayment(.options(.init(
                lastPayments: lastPayments,
                operators: operators
            ))))
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadSuccessOnEmptyState_nonEmptyLastPayments() {
        
        let lastPayments = [makeLastPayment()]
        let operators = [makeOperator()]
        let emptyState = State()
        
        assert(.loaded(.success(lastPayments, operators)), on: emptyState, effect: nil)
    }
    
    func test_loaded_shouldNotChangeNonEmptyStateOnLoadSuccess() {
        
        let lastPayments = [makeLastPayment()]
        let operators = [makeOperator()]
        let nonEmptyState = State(stack: .init(.services))
        
        assertState(.loaded(.success(lastPayments, operators)), on: nonEmptyState)
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadSuccessOnNonEmptyState() {
        
        let lastPayments = [makeLastPayment()]
        let operators = [makeOperator()]
        let nonEmptyState = State(stack: .init(.services))
        
        assert(.loaded(.success(lastPayments, operators)), on: nonEmptyState, effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityFlowReducer<LastPayment, Operator>
    
    private typealias Destination = UtilityDestination<LastPayment, Operator>
    
    private typealias State = Flow<Destination>
    private typealias Event = UtilityFlowEvent<LastPayment, Operator>
    private typealias Effect = UtilityFlowEffect
    
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
}

final class UtilityFlowEffectHandler<LastPayment, Operator> {
    
    private let load: Load
    
    init(load: @escaping Load) {
        
        self.load = load
    }
}

extension UtilityFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .initiate:
            load {
                
                switch $0 {
                case .failure:
                    dispatch(.loaded(.failure))
                    
                case let .success((lastPayments, operators)):
                    if operators.isEmpty {
                        dispatch(.loaded(.failure))
                    } else {
                        dispatch(.loaded(.success(lastPayments, operators)))
                    }
                }
            }
        }
    }
}

extension UtilityFlowEffectHandler {
    
    typealias Response = ([LastPayment], [Operator])
    typealias LoadResult = Result<Response, Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityFlowEvent<LastPayment, Operator>
    typealias Effect = UtilityFlowEffect
}

final class UtilityFlowEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
    }
    
    func test_initiate_shouldDeliverFailureOnLoadFailure() {
        
        let (sut, loader) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.failure)) {
            
            loader.complete(with: .failure(anyError()))
        }
    }
    
    func test_initiate_shouldDeliverFailureOnEmptyOperatorListLoadSuccess_emptyLastPayments() {
        
        let (sut, loader) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.failure)) {
            
            loader.complete(with: .success(([], [])))
        }
    }
    
    func test_initiate_shouldDeliverFailureOnEmptyOperatorListLoadSuccess_nonEmptyLastPayments() {
        
        let (sut, loader) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.failure)) {
            
            loader.complete(with: .success(([makeLastPayment()], [])))
        }
    }
    
    func test_initiate_shouldDeliverOperatorListLoadSuccess_emptyLastPayments() {
        
        let `operator` = makeOperator()
        let (sut, loader) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.success([], [`operator`]))) {
            
            loader.complete(with: .success(([], [`operator`])))
        }
    }
    
    func test_initiate_shouldDeliverOperatorListLoadSuccess_nonEmptyLastPayments() {
        
        let lastPayment = makeLastPayment()
        let `operator` = makeOperator()
        let (sut, loader) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.success([lastPayment], [`operator`]))) {
            
            loader.complete(with: .success(([lastPayment], [`operator`])))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityFlowEffectHandler<LastPayment, Operator>
    
    private typealias Destination = UtilityDestination<LastPayment, Operator>
    
    private typealias State = Flow<Destination>
    private typealias Event = UtilityFlowEvent<LastPayment, Operator>
    private typealias Effect = UtilityFlowEffect
    
    private typealias LoaderSpy = Spy<Void, SUT.LoadResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loader: LoaderSpy
    ) {
        let loader = LoaderSpy()
        let sut = SUT(load: loader.process)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvents: Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}

final class UtilityFlowIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, loader) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
    }
    
    func test_loadFailureFlow() {
        
        let (sut, spy, loader) = makeSUT()
        
        sut.event(.initiate)
        loader.complete(with: .failure(anyError()))
        
        assert(
            spy,
            .init(), {
                _ in
            }, {
                _ in
            }, {
                $0.push(.prepayment(.failure))
            }
        )
    }
    
    func test_flow() {
        
        let lastPayments = [makeLastPayment()]
        let `operator` = makeOperator()
        let operators = [`operator`, makeOperator()]
        let options = Options(lastPayments: lastPayments, operators: operators)
        let (sut, spy, loader) = makeSUT()
        
        sut.event(.initiate)
        loader.complete(with: .success((lastPayments, operators)))
        
        assert(
            spy,
            .init(), {
                _ in
            }, {
                _ in
            }, {
                $0.push(.prepayment(.options(options)))
            }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    
    private typealias Destination = UtilityDestination<LastPayment, Operator>
    
    private typealias State = Flow<Destination>
    private typealias Event = UtilityFlowEvent<LastPayment, Operator>
    private typealias Effect = UtilityFlowEffect
    
    private typealias Options = Destination.Prepayment.Options
    
    private typealias Reducer = UtilityFlowReducer<LastPayment, Operator>
    private typealias EffectHandler = UtilityFlowEffectHandler<LastPayment, Operator>
    
    private typealias StateSpy = ValueSpy<State>
    
    private typealias LoaderSpy = Spy<Void, EffectHandler.LoadResult>
    
    private func makeSUT(
        initialState: State = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy,
        loader: LoaderSpy
    ) {
        let reducer = Reducer()
        
        let loader = LoaderSpy()
        let effectHandler = EffectHandler(load: loader.process)
        
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .immediate
        )
        
        let spy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, spy, loader)
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
