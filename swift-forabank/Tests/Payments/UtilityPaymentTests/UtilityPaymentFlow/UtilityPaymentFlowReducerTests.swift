//
//  UtilityPaymentFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 08.03.2024.
//

import PrePaymentPicker
import UtilityPayment
import XCTest

final class UtilityPaymentFlowReducerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, ppoReducer) = makeSUT()
        
        XCTAssertEqual(ppoReducer.callCount, 0)
    }
    
    // MARK: - PrePaymentOptionsEvent
    
    func test_prePaymentOptionsEvent_shouldNotChangeEmptyFlow_didScrollTo() {
        
        let state = makeState(flows: [])
        let event: Event = .prePaymentOptions(.didScrollTo("abc"))
        
        assertState(event, on: state)
        
        XCTAssertNil(state.current)
    }
    
    func test_prePaymentOptionsEvent_shouldChangeEmptyFlow_initiate() {
        
        let state = makeState(flows: [])
        let event: Event = .prePaymentOptions(.initiate)
        
        assertState(event, on: state) {
            
            $0.push(.prePaymentOptions(.init()))
        }
        
        XCTAssertNil(state.current)
    }
    
    func test_prePaymentOptionsEvent_shouldNotChangeEmptyFlow_paginatedFailure() {
        
        let state = makeState(flows: [])
        let event: Event = .prePaymentOptions(.paginated(.failure(.connectivityError)))
        
        assertState(event, on: state)
        
        XCTAssertNil(state.current)
    }
    
    func test_prePaymentOptionsEvent_shouldNotChangeEmptyFlow_paginatedSuccess() {
        
        let state = makeState(flows: [])
        let event: Event = .prePaymentOptions(.paginated(.success([
            makeOperator(), makeOperator()
        ])))
        
        assertState(event, on: state)
        
        XCTAssertNil(state.current)
    }
    
    func test_prePaymentOptionsEvent_shouldNotChangeEmptyFlow_search() {
        
        let state = makeState(flows: [])
        let event: Event = .prePaymentOptions(.search(.entered("abc")))
        
        assertState(event, on: state)
        
        XCTAssertNil(state.current)
    }
    
    func test_prePaymentOptionsEvent_loaded_shouldSetInitialFlow_loadLastPaymentFailure_loadOperatorsFailure() {
        
        let state = makeState(flows: [])
        let event: Event = .prePaymentOptions(.loaded(
            .failure(.connectivityError), .failure(.connectivityError)
        ))
        
        assertState(event, on: state) {
            
            $0.current = .prePaymentOptions(.init())
        }
        
        XCTAssertNil(state.current)
    }
    
    func test_prePaymentOptionsEvent_loaded_shouldSetInitialFlow_loadLastPaymentSuccess_loadOperatorsFailure() {
        
        let state = makeState(flows: [])
        let lastPayments = [makeLastPayment(), makeLastPayment()]
        let event: Event = .prePaymentOptions(.loaded(
            .success(lastPayments), .failure(.connectivityError)
        ))
        
        assertState(event, on: state) {
            
            $0.current = .prePaymentOptions(.init(
                lastPayments: lastPayments
            ))
        }
        
        XCTAssertNil(state.current)
    }
    
    func test_prePaymentOptionsEvent_loaded_shouldSetInitialFlow_loadLastPaymentFailure_loadOperatorsSuccess() {
        
        let state = makeState(flows: [])
        let operators = [makeOperator(), makeOperator()]
        let event: Event = .prePaymentOptions(.loaded(
            .failure(.connectivityError), .success(operators)
        ))
        
        assertState(event, on: state) {
            
            $0.current = .prePaymentOptions(.init(
                operators: operators
            ))
        }
        
        XCTAssertNil(state.current)
    }
    
    func test_prePaymentOptionsEvent_loaded_shouldSetInitialFlow_loadLastPaymentSuccessEmpty_loadOperatorsSuccessEmpty() {
        
        let state = makeState(flows: [])
        let lastPayments = [LastPayment]()
        let operators = [Operator]()
        let event: Event = .prePaymentOptions(.loaded(
            .success(lastPayments), .success(operators)
        ))
        
        assertState(event, on: state) {
            
            $0.current = .prePaymentOptions(.init(
                lastPayments: lastPayments,
                operators: operators
            ))
        }
        
        XCTAssertNil(state.current)
    }
    
    func test_prePaymentOptionsEvent_loaded_shouldSetInitialFlow_loadLastPaymentSuccess_loadOperatorsSuccess() {
        
        let state = makeState(flows: [])
        let lastPayments = [makeLastPayment()]
        let operators = [makeOperator(), makeOperator()]
        let event: Event = .prePaymentOptions(.loaded(
            .success(lastPayments), .success(operators)
        ))
        
        assertState(event, on: state) {
            
            $0.current = .prePaymentOptions(.init(
                lastPayments: lastPayments,
                operators: operators
            ))
        }
        
        XCTAssertNil(state.current)
    }
    
    func test_prePaymentOptionsEvent_loaded_shouldChangeNonEmptyFlow() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let event: Event = .prePaymentOptions(.loaded(
            .failure(.connectivityError), .failure(.connectivityError)
        ))
        
        assertState(event, on: state)
        
        XCTAssertNotNil(state.current)
    }
    
    func test_prePaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_didScrollTo() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let prePaymentOptionsEvent: PPOEvent = .didScrollTo("abc")
        let (sut, ppoReducer) = makeSUT()
        
        _ = sut.reduce(state, .prePaymentOptions(prePaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prePaymentOptionsEvent])
    }
    
    func test_prePaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_initiate() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let prePaymentOptionsEvent: PPOEvent = .initiate
        let (sut, ppoReducer) = makeSUT()
        
        _ = sut.reduce(state, .prePaymentOptions(prePaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prePaymentOptionsEvent])
    }
    
    func test_prePaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_loaded() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let prePaymentOptionsEvent: PPOEvent = .loaded(
            .failure(.connectivityError),
            .failure(.connectivityError)
        )
        let (sut, ppoReducer) = makeSUT()
        
        _ = sut.reduce(state, .prePaymentOptions(prePaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prePaymentOptionsEvent])
    }
    
    func test_prePaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_paginated() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let prePaymentOptionsEvent: PPOEvent = .paginated(
            .failure(.connectivityError)
        )
        let (sut, ppoReducer) = makeSUT()
        
        _ = sut.reduce(state, .prePaymentOptions(prePaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prePaymentOptionsEvent])
    }
    
    func test_prePaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_search() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let prePaymentOptionsEvent: PPOEvent = .search(.entered(""))
        let (sut, ppoReducer) = makeSUT()
        
        _ = sut.reduce(state, .prePaymentOptions(prePaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prePaymentOptionsEvent])
    }
    
    func test_prePaymentOptionsEvent_shouldChangePrePaymentOptionsStateToPrePaymentOptionsReduceResult() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let event: Event = .prePaymentOptions(.initiate)
        let (ppoStateStub, ppoEffectStub) = makePPOStub(
            lastPaymentsCount: 1,
            operatorsCount: 3,
            searchText: "abc",
            ppoEffect: .search("abc")
        )
        let (sut, _) = makeSUT(ppoStub: [(ppoStateStub, ppoEffectStub)])
        
        assertState(sut: sut, event, on: state) {
            
            $0 = self.makeState(.prePaymentOptions(ppoStateStub))
        }
    }
    
    func test_prePaymentOptionsEvent_shouldDeliverPrePaymentOptionsReduceEffect() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let event: Event = .prePaymentOptions(.initiate)
        let ppoStateStub = makePrePaymentOptionsState(
            lastPaymentsCount: 1,
            operatorsCount: 3,
            searchText: "abc"
        )
        let ppoEffectStub: PPOEffect = .search("abc")
        let (sut, _) = makeSUT(ppoStub: [(ppoStateStub, ppoEffectStub)])
        
        assert(sut: sut, event, on: state, effect: .prePaymentOptions(ppoEffectStub))
    }
    
    func test_prePaymentOptionsEvent_shouldChangeInflightOnPrePaymentOptionsInlight() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeState(.prePaymentOptions(prePaymentOptions))
        let event: Event = .prePaymentOptions(.initiate)
        let ppoStateStub = makePrePaymentOptionsState(
            lastPaymentsCount: 1,
            operatorsCount: 3,
            searchText: "abc",
            isInflight: true
        )
        let ppoEffectStub: PPOEffect = .search("abc")
        let (sut, _) = makeSUT(ppoStub: [(ppoStateStub, ppoEffectStub)])
        
        assertState(sut: sut, event, on: state) {
            
            $0 = .init([.prePaymentOptions(ppoStateStub)], status: .inflight)
        }
    }
    
    // MARK: - back
    
    func test_back_shouldNotChangeStateOnPrePaymentOptionsStatusFailure() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            status: .failure(.connectivityError)
        )
        
        assertState(.back, on: state)
    }
    
    func test_back_shouldNotDeliverEffectOnPrePaymentOptionsStatusFailure() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            status: .failure(.connectivityError)
        )
        
        assert(.back, on: state, effect: nil)
    }
    
    func test_back_shouldNotChangeStateOnPrePaymentStatusFailure() {
        
        let state = makeState(
            makeSelectingServicesState(),
            status: .failure(.serverError(anyMessage()))
        )
        
        assertState(.back, on: state)
    }
    
    func test_back_shouldNotDeliverEffectOnPrePaymentStatusFailure() {
        
        let state = makeState(
            makeSelectingServicesState(),
            status: .failure(.serverError(anyMessage()))
        )
        
        assert(.back, on: state, effect: nil)
    }
    
    func test_back_shouldChangeStateToEmptyOnPrePaymentOptions() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assertState(.back, on: state) {
            
            $0.current = nil
        }
    }
    
    func test_back_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assert(.back, on: state, effect: nil)
    }
    
    func test_back_shouldChangePrePaymentStateToPrePaymentOptions_payingByInstruction() {
        
        let prePaymentOptions: Flow = .prePaymentOptions(makePrePaymentOptionsState())
        let state = makeState(
            prePaymentOptions,
            .prePaymentState(.payingByInstruction)
        )
        
        assertState(.back, on: state) {
            
            $0 = .init([prePaymentOptions])
        }
    }
    
    func test_back_shouldNotDeliverEffectOnPrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assert(.back, on: state, effect: nil)
    }
    
    func test_back_shouldChangePrePaymentStateToPrePaymentOptions_scanning() {
        
        let prePaymentOptions: Flow = .prePaymentOptions(makePrePaymentOptionsState())
        let state = makeState(
            prePaymentOptions,
            .prePaymentState(.scanning)
        )
        
        assertState(.back, on: state){
            
            $0 = .init([prePaymentOptions])
        }
    }
    
    func test_back_shouldNotDeliverEffectOnPrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assert(.back, on: state, effect: nil)
    }
    func test_loadedFailure_back_shouldNotChangeState() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let (sut, _) = makeSUT()
        let loadedEvent: Event = .prePayment(.loaded(.failure))
        
        let (loaded, _) = sut.reduce(initialState, loadedEvent)
        let (final, _) = sut.reduce(loaded, .back)
        
        XCTAssertNoDiff(final, initialState)
    }
    
    func test_loadedFailure_back_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let (sut, _) = makeSUT()
        let loadedEvent: Event = .prePayment(.loaded(.failure))
        
        let (loaded, firstEffect) = sut.reduce(initialState, loadedEvent)
        let (_, lastEffect) = sut.reduce(loaded, .back)
        
        XCTAssertNil(firstEffect)
        XCTAssertNil(lastEffect)
    }
    
    func test_loadedEmptySuccess_back_shouldNotChangeState() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let (sut, _) = makeSUT()
        let loadedEvent: Event = .prePayment(.loaded(.list(makeOperator(), [])))
        
        let (loaded, _) = sut.reduce(initialState, loadedEvent)
        let (final, _) = sut.reduce(loaded, .back)
        
        XCTAssertNoDiff(final, initialState)
    }
    
    func test_loadedEmptySuccess_back_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let (sut, _) = makeSUT()
        let loadedEvent: Event = .prePayment(.loaded(.list(makeOperator(), [])))
        
        let (loaded, firstEffect) = sut.reduce(initialState, loadedEvent)
        let (_, lastEffect) = sut.reduce(loaded, .back)
        
        XCTAssertNil(firstEffect)
        XCTAssertNil(lastEffect)
    }
    
    func test_loadedOneSuccess_back_shouldNotChangeState() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let (sut, _) = makeSUT()
        let loadedEvent: Event = .prePayment(.loaded(.list(makeOperator(), [makeService()])))
        
        let (loaded, _) = sut.reduce(initialState, loadedEvent)
        let (final, _) = sut.reduce(loaded, .back)
        
        XCTAssertNoDiff(final, initialState)
    }
    
    func test_loadedOneSuccess_back_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let (sut, _) = makeSUT()
        let loadedEvent: Event = .prePayment(.loaded(.list(makeOperator(), [makeService()])))
        
        let (loaded, firstEffect) = sut.reduce(initialState, loadedEvent)
        let (_, lastEffect) = sut.reduce(loaded, .back)
        
        XCTAssertNil(firstEffect)
        XCTAssertNil(lastEffect)
    }
    
    func test_loadedManySuccess_back_shouldRevertStateToInitialPrePaymentOptionsState() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let (sut, _) = makeSUT()
        let loadedEvent: Event = .prePayment(.loaded(.list(makeOperator(), [makeService(), makeService()])))
        
        let (loaded, _) = sut.reduce(initialState, loadedEvent)
        let (final, _) = sut.reduce(loaded, .back)
        
        XCTAssertNoDiff(final, initialState)
    }
    
    func test_loadedManySuccess_back_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let (sut, _) = makeSUT()
        let loadedEvent: Event = .prePayment(.loaded(.list(makeOperator(), [makeService(), makeService()])))
        
        let (loaded, firstEffect) = sut.reduce(initialState, loadedEvent)
        let (_, lastEffect) = sut.reduce(loaded, .back)
        
        XCTAssertNil(firstEffect)
        XCTAssertNil(lastEffect)
    }
    func test_payByInstruction_back_shouldRevertStateToInitialPrePaymentOptionsState() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let (sut, _) = makeSUT()
        
        let (state, _) = sut.reduce(initialState, .prePayment(.payByInstruction))
        let (final, _) = sut.reduce(state, .back)
        
        XCTAssertNoDiff(final, initialState)
    }
    
    func test_payByInstruction_back_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let (sut, _) = makeSUT()
        
        let (state, firstEffect) = sut.reduce(initialState, .prePayment(.payByInstruction))
        let (_, lastEffect) = sut.reduce(state, .back)
        
        XCTAssertNil(firstEffect)
        XCTAssertNil(lastEffect)
    }
    
    func test_scan_back_shouldRevertStateToInitialPrePaymentOptionsState() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let (sut, _) = makeSUT()
        
        let (state, _) = sut.reduce(initialState, .prePayment(.scan))
        let (final, _) = sut.reduce(state, .back)
        
        XCTAssertNoDiff(final, initialState)
    }
    
    func test_scan_back_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let (sut, _) = makeSUT()
        
        let (state, firstEffect) = sut.reduce(initialState, .prePayment(.scan))
        let (_, lastEffect) = sut.reduce(state, .back)
        
        XCTAssertNil(firstEffect)
        XCTAssertNil(lastEffect)
    }
    
    func test_paymentStarted_back_shouldNotDeliverEffectOnPrePaymentOptionsState_connectivityError() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let event: Event = .prePayment(.paymentStarted(.failure(.connectivityError)))
        let (sut, _) = makeSUT()
        
        let (state, firstEffect) = sut.reduce(initialState, event)
        let (_, lastEffect) = sut.reduce(state, .back)
        
        XCTAssertNil(firstEffect)
        XCTAssertNil(lastEffect)
    }
    
    func test_paymentStarted_back_shouldNotDeliverEffectOnPrePaymentOptionsState_serverError() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let event: Event = .prePayment(.paymentStarted(.failure(.serverError(anyMessage()))))
        let (sut, _) = makeSUT()
        
        let (state, firstEffect) = sut.reduce(initialState, event)
        let (_, lastEffect) = sut.reduce(state, .back)
        
        XCTAssertNil(firstEffect)
        XCTAssertNil(lastEffect)
    }
    
    func test_paymentStarted_back_shouldNotDeliverEffectOnPrePaymentOptionsState_success() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let event: Event = .prePayment(.paymentStarted(.success(makeResponse())))
        let (sut, _) = makeSUT()
        
        let (state, firstEffect) = sut.reduce(initialState, event)
        let (_, lastEffect) = sut.reduce(state, .back)
        
        XCTAssertNil(firstEffect)
        XCTAssertNil(lastEffect)
    }
    
    func test_paymentStarted_back_shouldNotDeliverEffectOnPrePaymentState_connectivityError() {
        
        let initialState = makeState(makeSelectingServicesState())
        let event: Event = .prePayment(.paymentStarted(.failure(.connectivityError)))
        let (sut, _) = makeSUT()
        
        let (state, firstEffect) = sut.reduce(initialState, event)
        let (_, lastEffect) = sut.reduce(state, .back)
        
        XCTAssertNil(firstEffect)
        XCTAssertNil(lastEffect)
    }
    
    func test_paymentStarted_back_shouldNotDeliverEffectOnPrePaymentState_serverError() {
        
        let initialState = makeState(makeSelectingServicesState())
        let event: Event = .prePayment(.paymentStarted(.failure(.serverError(anyMessage()))))
        let (sut, _) = makeSUT()
        
        let (state, firstEffect) = sut.reduce(initialState, event)
        let (_, lastEffect) = sut.reduce(state, .back)
        
        XCTAssertNil(firstEffect)
        XCTAssertNil(lastEffect)
    }
    
    func test_paymentStarted_back_shouldNotDeliverEffectOnPrePaymentState_success() {
        
        let initialState = makeState(makeSelectingServicesState())
        let event: Event = .prePayment(.paymentStarted(.success(makeResponse())))
        let (sut, _) = makeSUT()
        
        let (state, firstEffect) = sut.reduce(initialState, event)
        let (_, lastEffect) = sut.reduce(state, .back)
        
        XCTAssertNil(firstEffect)
        XCTAssertNil(lastEffect)
    }
    
    // MARK: - payByInstruction
    
    func test_prePaymentEvent_payByInstruction_shouldChangePrePaymentOptionsStateToPrePaymentStatePayingByInstruction() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assertState(.prePayment(.payByInstruction), on: state) {
            
            $0.push(.prePaymentState(.payingByInstruction))
        }
    }
    
    func test_prePaymentEvent_payByInstruction_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assert(.prePayment(.payByInstruction), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_payByInstruction_shouldNotChangePrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assertState(.prePayment(.payByInstruction), on: state)
    }
    
    func test_prePaymentEvent_payByInstruction_shouldNotDeliverEffectOnPrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assert(.prePayment(.payByInstruction), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_payByInstruction_shouldNotChangePrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assertState(.prePayment(.payByInstruction), on: state)
    }
    
    func test_prePaymentEvent_payByInstruction_shouldNotDeliverEffectOnPrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assert(.prePayment(.payByInstruction), on: state, effect: nil)
    }
    
    // MARK: - paymentStarted on PrePaymentOption State
    
    func test_paymentStarted_shouldChangePrePaymentOptionsState_connectivityError() {
        
        let prePaymentOptionsState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let event: Event = .prePayment(.paymentStarted(.failure(.connectivityError)))
        
        assertState(event, on: prePaymentOptionsState) {
            
            $0.status = .failure(.connectivityError)
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnPrePaymentOptionsState_connectivityError() {
        
        let prePaymentOptionsState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let event: Event = .prePayment(.paymentStarted(.failure(.connectivityError)))
        
        assert(event, on: prePaymentOptionsState, effect: nil)
    }
    
    func test_paymentStarted_shouldChangePrePaymentOptionsState_serverError() {
        
        let prePaymentOptionsState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let message = anyMessage()
        let event: Event = .prePayment(.paymentStarted(.failure(.serverError(message))))
        
        assertState(event, on: prePaymentOptionsState) {
            
            $0.status = .failure(.serverError(message))
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnPrePaymentOptionsState_serverError() {
        
        let prePaymentOptionsState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let message = anyMessage()
        let event: Event = .prePayment(.paymentStarted(.failure(.serverError(message))))
        
        assert(event, on: prePaymentOptionsState, effect: nil)
    }
    
    func test_paymentStarted_shouldChangePrePaymentOptionsState_success() {
        
        let prePaymentOptionsState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let event: Event = .prePayment(.paymentStarted(.success(makeResponse())))
        
        assertState(event, on: prePaymentOptionsState) {
            
            $0.push(.payment)
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnPrePaymentOptionsState_success() {
        
        let initialState = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        let event: Event = .prePayment(.paymentStarted(.success(makeResponse())))
        
        assert(event, on: initialState, effect: nil)
    }
    
    func test_paymentStarted_shouldChangePrePaymentOptionsStateInflight_success() {
        
        let prePaymentOptionsState = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            status: .inflight
        )
        let event: Event = .prePayment(.paymentStarted(.success(makeResponse())))
        
        assertState(event, on: prePaymentOptionsState) {
            
            $0.push(.payment)
            $0.status = nil
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnPrePaymentOptionsStateInflight_success() {
        
        let initialState = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            status: .inflight
        )
        let event: Event = .prePayment(.paymentStarted(.success(makeResponse())))
        
        assert(event, on: initialState, effect: nil)
    }
    
    // MARK: - paymentStarted on PrePayment State
    
    func test_paymentStarted_shouldChangePrePaymentState_connectivityError() {
        
        let prePaymentState = makeState(makeSelectingServicesState())
        let event: Event = .prePayment(.paymentStarted(.failure(.connectivityError)))
        
        assertState(event, on: prePaymentState) {
            
            $0.status = .failure(.connectivityError)
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnPrePaymentState_connectivityError() {
        
        let prePaymentState = makeState(makeSelectingServicesState())
        let event: Event = .prePayment(.paymentStarted(.failure(.connectivityError)))
        
        assert(event, on: prePaymentState, effect: nil)
    }
    
    func test_paymentStarted_shouldChangePrePaymentState_serverError() {
        
        let prePaymentState = makeState(makeSelectingServicesState())
        let message = anyMessage()
        let event: Event = .prePayment(.paymentStarted(.failure(.serverError(message))))
        
        assertState(event, on: prePaymentState) {
            
            $0.status = .failure(.serverError(message))
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnPrePaymentState_serverError() {
        
        let prePaymentState = makeState(makeSelectingServicesState())
        let message = anyMessage()
        let event: Event = .prePayment(.paymentStarted(.failure(.serverError(message))))
        
        assert(event, on: prePaymentState, effect: nil)
    }
    
    func test_paymentStarted_shouldChangePrePaymentState_success() {
        
        let prePaymentState = makeState(makeSelectingServicesState())
        let message = anyMessage()
        let event: Event = .prePayment(.paymentStarted(.success(makeResponse())))
        
        assertState(event, on: prePaymentState) {
            
            $0.push(.payment)
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnPrePaymentState_success() {
        
        let prePaymentState = makeState(makeSelectingServicesState())
        let message = anyMessage()
        let event: Event = .prePayment(.paymentStarted(.success(makeResponse())))
        
        assert(event, on: prePaymentState, effect: nil)
    }
    
    // MARK: - scan
    
    func test_prePaymentEvent_scan_shouldNotChangePrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assertState(.prePayment(.scan), on: state)
    }
    
    func test_prePaymentEvent_scan_shouldNotDeliverEffectOnPrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assert(.prePayment(.scan), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_scan_shouldNotChangePrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assertState(.prePayment(.scan), on: state)
    }
    
    func test_prePaymentEvent_scan_shouldNotDeliverEffectOnPrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assert(.prePayment(.scan), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_scan_shouldChangePrePaymentOptionsStateTo_____() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assertState(.prePayment(.scan), on: state) {
            
            $0.push(.prePaymentState(.scanning))
        }
    }
    
    func test_prePaymentEvent_scan_shouldNotDeliverEffectOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assert(.prePayment(.scan), on: state, effect: nil)
    }
    
    // MARK: - select
    
    func test_prePaymentEvent_selectLastPayment_shouldChangeStateToInflightOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assertState(selectLastPayment(), on: state) { $0.isInflight = true }
    }
    
    func test_prePaymentEvent_selectLastPayment_shouldDeliverStartPaymentEffectOnPrePaymentOptionsState() {
        
        let lastPayment = makeLastPayment()
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assert(selectLastPayment(lastPayment), on: state, effect: .prePayment(.select(.last(lastPayment))))
    }
    
    func test_prePaymentEvent_selectOperator_shouldChangeStateToInflightOnPrePaymentOptionsState() {
        
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assertState(selectOperator(), on: state) { $0.isInflight = true }
    }
    
    func test_prePaymentEvent_selectOperator_shouldDeliverStartPaymentEffectOnPrePaymentOptionsState() {
        
        let `operator` = makeOperator()
        let state = makeState(.prePaymentOptions(makePrePaymentOptionsState()))
        
        assert(selectOperator(`operator`), on: state, effect: .prePayment(.select(.operator(`operator`))))
    }
    
    func test_prePaymentEvent_selectLastPayment_shouldNorChangePrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assertState(selectLastPayment(), on: state)
    }
    
    func test_prePaymentEvent_selectLastPayment_shouldNotDeliverEffectOnPrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assert(selectLastPayment(), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_selectLastPayment_shouldNorChangePrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assertState(selectLastPayment(), on: state)
    }
    
    func test_prePaymentEvent_selectLastPayment_shouldNotDeliverEffectOnPrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assert(selectLastPayment(), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_selectOperator_shouldNotChangePrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assertState(selectOperator(), on: state)
    }
    
    func test_prePaymentEvent_selectOperator_shouldNotDeliverEffectOnPrePaymentState_payingByInstruction() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.payingByInstruction)
        )
        
        assert(selectOperator(), on: state, effect: nil)
    }
    
    func test_prePaymentEvent_selectOperator_shouldNotChangePrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assertState(selectOperator(), on: state)
    }
    
    func test_prePaymentEvent_selectOperator_shouldNotDeliverEffectOnPrePaymentState_scanning() {
        
        let state = makeState(
            .prePaymentOptions(makePrePaymentOptionsState()),
            .prePaymentState(.scanning)
        )
        
        assert(selectOperator(), on: state, effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityPaymentFlowReducer<LastPayment, Operator, StartPaymentResponse, Service>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias Flow = SUT.State.Destination
    
    private typealias PPOState = SUT.PPOState
    private typealias PPOEvent = SUT.PPOEvent
    private typealias PPOEffect = SUT.PPOEffect
    private typealias PPOReducer = ReducerSpy<PPOState, PPOEvent, PPOEffect>
    
    private typealias PPState = SUT.PPState
    private typealias PPEvent = SUT.PPEvent
    private typealias PPEffect = SUT.PPEffect
    
    private func makeSUT(
        ppoStub: [(PPOState, PPOEffect?)] = [(.init(), nil)],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        ppoReducer: PPOReducer
    ) {
        let ppoReducer = PPOReducer(stub: ppoStub)
        let sut = SUT(
            prePaymentOptionsReduce: ppoReducer.reduce
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(ppoReducer, file: file, line: line)
        
        return (sut, ppoReducer)
    }
    
    private func makePPOStub(
        lastPaymentsCount: Int? = nil,
        operatorsCount: Int? = nil,
        searchText: String = "",
        isInflight: Bool = false,
        ppoEffect: PPOEffect? = nil
    ) -> (PPOState, PPOEffect?) {
        
        let ppoState = makePrePaymentOptionsState(
            lastPaymentsCount: lastPaymentsCount,
            operatorsCount: operatorsCount,
            searchText: searchText,
            isInflight: isInflight
        )
        
        return (ppoState, ppoEffect)
    }
    
    private func makePrePaymentOptionsState(
        lastPaymentsCount: Int? = nil,
        operatorsCount: Int? = nil,
        searchText: String = "",
        isInflight: Bool = false
    ) -> PPOState {
        
        .init(
            lastPayments: lastPaymentsCount.map {
                (0..<$0).map { _ in makeLastPayment() }
            },
            operators: operatorsCount.map {
                (0..<$0).map { _ in makeOperator() }
            },
            searchText: searchText,
            isInflight: isInflight
        )
    }
    
    private func makeSelectingServicesState(
        _ `operator`: Operator = makeOperator(),
        _ services: [Service]? = nil
    ) -> Flow {
        
        .prePaymentState(.services(`operator`, services ?? [makeService(), makeService()]))
    }
    
    private func makeState(
        _ flows: Flow...,
        status: State.Status? = nil
    ) -> State {
        
        .init(flows, status: status)
    }
    
    private func makeState(
        flows: [Flow],
        status: State.Status? = nil
    ) -> State {
        
        .init(flows, status: status)
    }
    
    private func selectLastPayment(
        _ lastPayment: LastPayment? = nil
    ) -> Event {
        
        .prePayment(.select(.last(lastPayment ?? makeLastPayment())))
    }
    
    private func selectOperator(
        _ `operator`: Operator? = nil
    ) -> Event {
        
        .prePayment(.select(.operator(`operator` ?? makeOperator())))
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
        let sut = sut ?? makeSUT(file: file, line: line).sut
        
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
        let sut = sut ?? makeSUT(file: file, line: line).sut
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
