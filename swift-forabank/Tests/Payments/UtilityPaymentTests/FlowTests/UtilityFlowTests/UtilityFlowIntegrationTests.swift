//
//  UtilityFlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

enum UtilityFlowEvent<LastPayment, Operator, StartPaymentResponse> {
    
    case back
    case initiate
    case loaded(Loaded)
    case paymentStarted(StartPaymentResult)
    case select(Select)
}

extension UtilityFlowEvent {
    
    enum Loaded {
        
        case failure
        case success([LastPayment], [Operator])
    }
    
    enum Select {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
    
    typealias StartPaymentResult = Result<StartPaymentResponse, ServiceFailure>
}

extension UtilityFlowEvent: Equatable where LastPayment: Equatable, Operator: Equatable, StartPaymentResponse: Equatable {}

extension UtilityFlowEvent.Loaded: Equatable where LastPayment: Equatable, Operator: Equatable {}
extension UtilityFlowEvent.Select: Equatable where LastPayment: Equatable, Operator: Equatable {}

enum UtilityFlowEffect<LastPayment, Operator> {
    
    case initiate
    case startPayment(StartPayment)
}

extension UtilityFlowEffect {
    
    enum StartPayment {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
}

extension UtilityFlowEffect: Equatable where LastPayment: Equatable, Operator: Equatable {}
extension UtilityFlowEffect.StartPayment: Equatable where LastPayment: Equatable, Operator: Equatable {}

final class UtilityFlowReducer<LastPayment, Operator, StartPaymentResponse> {
    
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
            
        case let .paymentStarted(result):
            switch result {
            case let .failure(serviceFailure):
                state.push(.failure(serviceFailure))
                
            case let .success(response):
                state.push(.payment)
            }
            
        case let .select(select):
            if case .prepayment = state.current {
                
                effect = .startPayment(select.startPayment)
            }
        }
        
        return (state, effect)
    }
}

private extension UtilityFlowEvent.Select {
    
    var startPayment: UtilityFlowEffect<LastPayment, Operator>.StartPayment {
        
        switch self {
        case let .last(lastPayment):
            return .last(lastPayment)
            
        case let .operator(`operator`):
            return .operator(`operator`)
        }
    }
}

extension UtilityFlowReducer {
    
    typealias Destination = UtilityDestination<LastPayment, Operator>
    
    typealias State = Flow<Destination>
    typealias Event = UtilityFlowEvent<LastPayment, Operator, StartPaymentResponse>
    typealias Effect = UtilityFlowEffect<LastPayment, Operator>
}

final class UtilityFlowReducerTests: XCTestCase {
    
    // MARK: - back
    
    func test_back_shouldNotChangeEmptyState() {
        
        let emptyState = makeState()
        
        assertState(.back, on: emptyState)
    }
    
    func test_back_shouldNotDeliverEffectOnEmptyState() {
        
        let emptyState = makeState()
        
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
        
        let emptyState = makeState()
        
        assertState(.initiate, on: emptyState)
    }
    
    func test_initiate_shouldDeliverEffectOnEmptyState() {
        
        let emptyState = makeState()
        
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
        
        let emptyState = makeState()
        
        assertState(.loaded(.failure), on: emptyState) {
            
            $0.push(.prepayment(.failure))
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadFailureOnEmptyState() {
        
        let emptyState = makeState()
        
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
        let emptyState = makeState()
        
        assertState(.loaded(.success([], operators)), on: emptyState) {
            
            $0.push(.prepayment(.options(.init(
                lastPayments: [],
                operators: operators
            ))))
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadSuccessOnEmptyState_emptyLastPayments() {
        
        let operators = [makeOperator()]
        let emptyState = makeState()
        
        assert(.loaded(.success([], operators)), on: emptyState, effect: nil)
    }
    
    func test_loaded_shouldChangeEmptyStateOnLoadSuccess_nonEmptyLastPayments() {
        
        let lastPayments = [makeLastPayment()]
        let operators = [makeOperator()]
        let emptyState = makeState()
        
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
        let emptyState = makeState()
        
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
    
    // MARK: - paymentStarted
    
    func test_paymentStarted_shouldPushFailureDestinationOnConnectivityErrorFailure() {
        
        let state = makeState()
        
        assertState(.paymentStarted(.failure(.connectivityError)), on: state) {
            
            $0.push(.failure(.connectivityError))
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        let state = makeState()
        
        assert(.paymentStarted(.failure(.connectivityError)), on: state, effect: nil)
    }
    
    func test_paymentStarted_shouldPushFailureDestinationOnServerErrorFailure() {
        
        let message = anyMessage()
        let state = makeState()
        
        assertState(.paymentStarted(.failure(.serverError(message))), on: state) {
            
            $0.push(.failure(.serverError(message)))
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnServerErrorFailure() {
        
        let message = anyMessage()
        let state = makeState()
        
        assert(.paymentStarted(.failure(.serverError(message))), on: state, effect: nil)
    }
    
    func test_paymentStarted_shouldPushPaymentDestinationOnSuccess() {
        
        let state = makeState()
        
        assertState(.paymentStarted(.success(makeResponse())), on: state) {
            
            $0.push(.payment)
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnSuccess() {
        
        let state = makeState()
        
        assert(.paymentStarted(.success(makeResponse())), on: state, effect: nil)
    }
    
    // MARK: - select
    
    func test_select_lastPayment_shouldNotChangeEmptyState() {
        
        let lastPayment = makeLastPayment()
        let emptyState = makeState()
        
        assertState(.select(.last(lastPayment)), on: emptyState)
    }
    
    func test_select_lastPayment_shouldNotDeliverEffectOnEmptyState() {
        
        let lastPayment = makeLastPayment()
        let emptyState = makeState()
        
        assert(.select(.last(lastPayment)), on: emptyState, effect: nil)
    }
    
    func test_select_lastPayment_shouldNotChangeTopPrepaymentState() {
        
        let lastPayment = makeLastPayment()
        let topPrepaymentState = State(stack: .init(.prepayment(.options(.init(
            lastPayments: [lastPayment],
            operators: [makeOperator()]
        )))))
        
        assertState(.select(.last(lastPayment)), on: topPrepaymentState)
    }
    
    func test_select_lastPayment_shouldDeliverEffectOnTopPrepaymentState() {
        
        let lastPayment = makeLastPayment()
        let topPrepaymentState = State(stack: .init(.prepayment(.options(.init(
            lastPayments: [lastPayment],
            operators: [makeOperator()]
        )))))
        
        assert(.select(.last(lastPayment)), on: topPrepaymentState, effect: .startPayment(.last(lastPayment)))
    }
    
    func test_select_lastPayment_shouldNotChangeTopServicesState() {
        
        let lastPayment = makeLastPayment()
        let topServicesState = State(stack: .init(.services))
        
        assert(.select(.last(lastPayment)), on: topServicesState, effect: nil)
    }
    
    func test_select_lastPayment_shouldNotDeliverEffectOnTopServicesState() {
        
        let lastPayment = makeLastPayment()
        let topServicesState = State(stack: .init(.services))
        
        assert(.select(.last(lastPayment)), on: topServicesState, effect: nil)
    }
    
    func test_select_operator_shouldNotChangeEmptyState() {
        
        let `operator` = makeOperator()
        let emptyState = makeState()
        
        assertState(.select(.operator(`operator`)), on: emptyState)
    }
    
    func test_select_operator_shouldNotDeliverEffectOnEmptyState() {
        
        let `operator` = makeOperator()
        let emptyState = makeState()
        
        assert(.select(.operator(`operator`)), on: emptyState, effect: nil)
    }
    
    func test_select_operator_shouldNotChangeTopPrepaymentState() {
        
        let `operator` = makeOperator()
        let topPrepaymentState = State(stack: .init(.prepayment(.options(.init(
            lastPayments: [],
            operators: [makeOperator()]
        )))))
        
        assertState(.select(.operator(`operator`)), on: topPrepaymentState)
    }
    
    func test_select_operator_shouldDeliverEffectOnTopPrepaymentState() {
        
        let `operator` = makeOperator()
        let topPrepaymentState = State(stack: .init(.prepayment(.options(.init(
            lastPayments: [],
            operators: [makeOperator()]
        )))))
        
        assert(.select(.operator(`operator`)), on: topPrepaymentState, effect: .startPayment(.operator(`operator`)))
    }
    
    func test_select_operator_shouldNotChangeTopServicesState() {
        
        let `operator` = makeOperator()
        let topServicesState = State(stack: .init(.services))
        
        assert(.select(.operator(`operator`)), on: topServicesState, effect: nil)
    }
    
    func test_select_operator_shouldNotDeliverEffectOnTopServicesState() {
        
        let `operator` = makeOperator()
        let topServicesState = State(stack: .init(.services))
        
        assert(.select(.operator(`operator`)), on: topServicesState, effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityFlowReducer<LastPayment, Operator, StartPaymentResponse>
    
    private typealias Destination = UtilityDestination<LastPayment, Operator>
    
    private typealias State = Flow<Destination>
    private typealias Event = UtilityFlowEvent<LastPayment, Operator, StartPaymentResponse>
    private typealias Effect = UtilityFlowEffect<LastPayment, Operator>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState() -> State {
        
        .init()
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

final class UtilityFlowEffectHandler<LastPayment, Operator, StartPaymentResponse> {
    
    private let load: Load
    private let startPayment: StartPayment
    
    init(
        load: @escaping Load,
        startPayment: @escaping StartPayment
    ) {
        self.load = load
        self.startPayment = startPayment
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
            
        case let .startPayment(payload):
            startPayment(.init(payload)) {
                
                dispatch(.paymentStarted($0))
            }
        }
    }
}

private extension UtilityFlowEffectHandler.StartPaymentPayload {
    
    init(_ payload: UtilityFlowEffect<LastPayment, Operator>.StartPayment) {
        
        switch payload {
        case let .last(lastPayment):
            self = .last(lastPayment)
            
        case let .operator(`operator`):
            self = .operator(`operator`)
        }
    }
}

extension UtilityFlowEffectHandler {
    
    typealias LoadResponse = ([LastPayment], [Operator])
    typealias LoadResult = Result<LoadResponse, Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    enum StartPaymentPayload {
        
        case last(LastPayment)
        case `operator`(Operator)
    }
    
    typealias StartPaymentResult = Result<StartPaymentResponse, ServiceFailure>
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    typealias StartPayment = (StartPaymentPayload, @escaping StartPaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = UtilityFlowEvent<LastPayment, Operator, StartPaymentResponse>
    typealias Effect = UtilityFlowEffect<LastPayment, Operator>
}

extension UtilityFlowEffectHandler.StartPaymentPayload: Equatable where LastPayment: Equatable, Operator: Equatable {}

final class UtilityFlowEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, loader, paymentStarter) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
        XCTAssertEqual(paymentStarter.callCount, 0)
    }
    
    // MARK: - initiate
    
    func test_initiate_shouldDeliverFailureOnLoadFailure() {
        
        let (sut, loader, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.failure)) {
            
            loader.complete(with: .failure(anyError()))
        }
    }
    
    func test_initiate_shouldDeliverFailureOnEmptyOperatorListLoadSuccess_emptyLastPayments() {
        
        let (sut, loader, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.failure)) {
            
            loader.complete(with: .success(([], [])))
        }
    }
    
    func test_initiate_shouldDeliverFailureOnEmptyOperatorListLoadSuccess_nonEmptyLastPayments() {
        
        let (sut, loader, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.failure)) {
            
            loader.complete(with: .success(([makeLastPayment()], [])))
        }
    }
    
    func test_initiate_shouldDeliverOperatorListLoadSuccess_emptyLastPayments() {
        
        let `operator` = makeOperator()
        let (sut, loader, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.success([], [`operator`]))) {
            
            loader.complete(with: .success(([], [`operator`])))
        }
    }
    
    func test_initiate_shouldDeliverOperatorListLoadSuccess_nonEmptyLastPayments() {
        
        let lastPayment = makeLastPayment()
        let `operator` = makeOperator()
        let (sut, loader, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.success([lastPayment], [`operator`]))) {
            
            loader.complete(with: .success(([lastPayment], [`operator`])))
        }
    }
    
    // MARK: - startPayment
    
    func test_startPayment_lastPayment_shouldCallPaymentStarterWithPayload() {
        
        let lastPayment = makeLastPayment()
        let (sut, _, paymentStarter) = makeSUT()
        
        sut.handleEffect(.startPayment(.last(lastPayment))) { _ in }
        
        XCTAssertNoDiff(paymentStarter.payloads, [.last(lastPayment)])
    }
    
    func test_startPayment_lastPayment_shouldDeliverConnectivityErrorOnConnectivityErrorFailure() {
        
        let lastPayment = makeLastPayment()
        let (sut, _, paymentStarter) = makeSUT()
        
        expect(sut, with: .startPayment(.last(lastPayment)), toDeliver: .paymentStarted(.failure(.connectivityError))) {
            
            paymentStarter.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_startPayment_lastPayment_shouldDeliverServerErrorOnServerErrorFailure() {
        
        let lastPayment = makeLastPayment()
        let message = anyMessage()
        let (sut, _, paymentStarter) = makeSUT()
        
        expect(sut, with: .startPayment(.last(lastPayment)), toDeliver: .paymentStarted(.failure(.serverError(message)))) {
            
            paymentStarter.complete(with: .failure(.serverError(message)))
        }
    }
    
    func test_startPayment_lastPayment_shouldDeliverResponseOnSuccess() {
        
        let lastPayment = makeLastPayment()
        let response = makeResponse()
        let (sut, _, paymentStarter) = makeSUT()
        
        expect(sut, with: .startPayment(.last(lastPayment)), toDeliver: .paymentStarted(.success(response))) {
            
            paymentStarter.complete(with: .success(response))
        }
    }
    
    func test_startPayment_operator_shouldCallPaymentStarterWithPayload() {
        
        let `operator` = makeOperator()
        let (sut, _, paymentStarter) = makeSUT()
        
        sut.handleEffect(.startPayment(.operator(`operator`))) { _ in }
        
        XCTAssertNoDiff(paymentStarter.payloads, [.operator(`operator`)])
    }
    
    func test_startPayment_operator_shouldDeliverConnectivityErrorOnConnectivityErrorFailure() {
        
        let `operator` = makeOperator()
        let (sut, _, paymentStarter) = makeSUT()
        
        expect(sut, with: .startPayment(.operator(`operator`)), toDeliver: .paymentStarted(.failure(.connectivityError))) {
            
            paymentStarter.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_startPayment_operator_shouldDeliverServerErrorOnServerErrorFailure() {
        
        let `operator` = makeOperator()
        let message = anyMessage()
        let (sut, _, paymentStarter) = makeSUT()
        
        expect(sut, with: .startPayment(.operator(`operator`)), toDeliver: .paymentStarted(.failure(.serverError(message)))) {
            
            paymentStarter.complete(with: .failure(.serverError(message)))
        }
    }
    
    func test_startPayment_operator_shouldDeliverResponseOnSuccess() {
        
        let `operator` = makeOperator()
        let response = makeResponse()
        let (sut, _, paymentStarter) = makeSUT()
        
        expect(sut, with: .startPayment(.operator(`operator`)), toDeliver: .paymentStarted(.success(response))) {
            
            paymentStarter.complete(with: .success(response))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityFlowEffectHandler<LastPayment, Operator, StartPaymentResponse>
    
    private typealias Destination = UtilityDestination<LastPayment, Operator>
    
    private typealias State = Flow<Destination>
    private typealias Event = UtilityFlowEvent<LastPayment, Operator, StartPaymentResponse>
    private typealias Effect = UtilityFlowEffect<LastPayment, Operator>
    
    private typealias LoaderSpy = Spy<Void, SUT.LoadResult>
    private typealias PaymentStarterSpy = Spy<SUT.StartPaymentPayload, SUT.StartPaymentResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loader: LoaderSpy,
        paymentStarter: PaymentStarterSpy
    ) {
        let paymentStarter = PaymentStarterSpy()
        let loader = LoaderSpy()
        let sut = SUT(
            load: loader.process,
            startPayment: paymentStarter.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(paymentStarter, file: file, line: line)
        
        return (sut, loader, paymentStarter)
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
    private typealias Event = UtilityFlowEvent<LastPayment, Operator, StartPaymentResponse>
    private typealias Effect = UtilityFlowEffect<LastPayment, Operator>
    
    private typealias Options = Destination.Prepayment.Options
    
    private typealias Reducer = UtilityFlowReducer<LastPayment, Operator, StartPaymentResponse>
    private typealias EffectHandler = UtilityFlowEffectHandler<LastPayment, Operator, StartPaymentResponse>
    
    private typealias StateSpy = ValueSpy<State>
    
    private typealias LoaderSpy = Spy<Void, EffectHandler.LoadResult>
    private typealias PaymentStarterSpy = Spy<EffectHandler.StartPaymentPayload, EffectHandler.StartPaymentResult>
    
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
        let paymentStarter = PaymentStarterSpy()
        let effectHandler = EffectHandler(
            load: loader.process,
            startPayment: paymentStarter.process
        )
        
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
