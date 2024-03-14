//
//  SimpleFlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

enum SimpleFlowEvent<LastPayment, Operator> {
    
    case initiate
    case loaded(Loaded)
}

extension SimpleFlowEvent {
    
    enum Loaded {
        
        case failure
        case success([LastPayment], [Operator])
    }
}

extension SimpleFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable {}

extension SimpleFlowEvent.Loaded: Equatable where LastPayment: Equatable, Operator: Equatable {}

enum SimpleFlowEffect {
    
    case initiate
}

extension SimpleFlowEffect: Equatable {}

final class SimpleFlowReducer<LastPayment, Operator> {
    
}

extension SimpleFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .initiate:
            switch state.current {
            case .none:
                effect = .initiate
                
            default:
                break
            }
            
        case let .loaded(loaded):
            switch loaded {
            case .failure:
                if state.current == nil {
                    state.current = .prepayment(.failure)
                }
                
            case let .success((lastPayments, operators)):
                switch state.current {
//                        case .none:
//                    state.push(.prepayment(.failure))
                    //
                    
                default:
                    break
                }
            }
        }
        
        return (state, effect)
    }
}

extension SimpleFlowReducer {
    
    typealias State = Flow<Destination>
    typealias Event = SimpleFlowEvent<LastPayment, Operator>
    typealias Effect = SimpleFlowEffect
}

final class SimpleFlowReducerTests: XCTestCase {
    
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
    
    // MARK: - Helpers
    
    private typealias SUT = SimpleFlowReducer<LastPayment, Operator>
    
    private typealias State = Flow<Destination>
    private typealias Event = SimpleFlowEvent<LastPayment, Operator>
    private typealias Effect = SimpleFlowEffect
    
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

final class SimpleFlowEffectHandler<LastPayment, Operator> {
    
    private let load: Load
    
    init(load: @escaping Load) {
        
        self.load = load
    }
}

extension SimpleFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
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

extension SimpleFlowEffectHandler {
    
    typealias Response = ([LastPayment], [Operator])
    typealias LoadResult = Result<Response, Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = SimpleFlowEvent<LastPayment, Operator>
    typealias Effect = SimpleFlowEffect
}

final class SimpleFlowEffectHandlerTests: XCTestCase {
    
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
    
    private typealias SUT = SimpleFlowEffectHandler<LastPayment, Operator>
    
    private typealias State = Flow<Destination>
    private typealias Event = SimpleFlowEvent<LastPayment, Operator>
    private typealias Effect = SimpleFlowEffect
    
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

final class SimpleFlowIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, loader) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
    }
    
    func test_flow() {
        
        let (sut, spy, loader) = makeSUT()
        
        sut.event(.initiate)
        loader.complete(with: .failure(anyError()))
        
        assert(
            spy,
            .init(), {
                _ in
            }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    
    private typealias State = Flow<Destination>
    private typealias Event = SimpleFlowEvent<LastPayment, Operator>
    private typealias Effect = SimpleFlowEffect
    
    private typealias Reducer = SimpleFlowReducer<LastPayment, Operator>
    private typealias EffectHandler = SimpleFlowEffectHandler<LastPayment, Operator>
    
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
            handleEffect: effectHandler.handleEffect(_:_:)
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
