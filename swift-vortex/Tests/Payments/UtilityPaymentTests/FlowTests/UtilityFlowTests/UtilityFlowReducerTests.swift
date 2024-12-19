//
//  UtilityFlowReducerTests.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment
import XCTest

final class UtilityFlowReducerTests: XCTestCase {
    
    // MARK: - back
    
    func test_back_shouldNotChangeEmptyState() {
        
        let emptyState = makeFlow()
        
        assertState(.back, on: emptyState)
    }
    
    func test_back_shouldNotDeliverEffectOnEmptyState() {
        
        let emptyState = makeFlow()
        
        assert(.back, on: emptyState, effect: nil)
    }
    
    func test_back_shouldChangeStateToEmptyOnSingleFlowState() {
        
        let singleFlow = makeSingleDestinationUtilityFlow()
        
        assertState(.back, on: singleFlow) {
            
            $0 = .init()
        }
    }
    
    func test_back_shouldNotDeliverEffectOnSingleFlowState() {
        
        let singleFlow = makeSingleDestinationUtilityFlow()
        
        assert(.back, on: singleFlow, effect: nil)
    }
    
    func test_back_shouldRemoveTopOnMultiFlowState() {
        
        let services = makeServices()
        let multiFlowState = makeFlow(.services(services), .prepayment(.failure))
        
        assertState(.back, on: multiFlowState) {
            
            $0 = .init(stack: .init(.services(services)))
        }
    }
    
    func test_back_shouldNotDeliverEffectOnMultiFlowState() {
        
        let services = makeServices()
        let multiFlowState = makeFlow(.services(services), .prepayment(.failure))
        
        assert(.back, on: multiFlowState, effect: nil)
    }
    
    // MARK: - initiatePrepayment
    
    func test_initiatePrepayment_shouldNotChangeEmptyState() {
        
        let emptyState = makeFlow()
        
        assertState(.initiatePrepayment, on: emptyState)
    }
    
    func test_initiatePrepayment_shouldDeliverEffectOnEmptyState() {
        
        let emptyState = makeFlow()
        
        assert(.initiatePrepayment, on: emptyState, effect: .initiatePrepayment)
    }
    
    func test_initiatePrepayment_shouldNotChangeNonEmptyState() {
        
        let nonEmptyState = makeSingleDestinationUtilityFlow()
        
        assertState(.initiatePrepayment, on: nonEmptyState)
    }
    
    func test_initiatePrepayment_shouldNotDeliverEffectOnNonEmptyState() {
        
        let nonEmptyState = makeSingleDestinationUtilityFlow()
        
        assert(.initiatePrepayment, on: nonEmptyState, effect: nil)
    }
    
    // MARK: - paymentStarted
    
    func test_paymentStarted_shouldPushFailureDestinationOnConnectivityErrorFailure() {
        
        let state = makeFlow()
        
        assertState(.paymentStarted(.failure(.connectivityError)), on: state) {
            
            $0.push(.failure(.connectivityError))
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        let state = makeFlow()
        
        assert(.paymentStarted(.failure(.connectivityError)), on: state, effect: nil)
    }
    
    func test_paymentStarted_shouldPushFailureDestinationOnServerErrorFailure() {
        
        let message = anyMessage()
        let state = makeFlow()
        
        assertState(.paymentStarted(.failure(.serverError(message))), on: state) {
            
            $0.push(.failure(.serverError(message)))
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnServerErrorFailure() {
        
        let message = anyMessage()
        let state = makeFlow()
        
        assert(.paymentStarted(.failure(.serverError(message))), on: state, effect: nil)
    }
    
    func test_paymentStarted_shouldPushPaymentDestinationOnSuccess() {
        
        let state = makeFlow()
        
        assertState(.paymentStarted(.success(makeResponse())), on: state) {
            
            $0.push(.payment)
        }
    }
    
    func test_paymentStarted_shouldNotDeliverEffectOnSuccess() {
        
        let state = makeFlow()
        
        assert(.paymentStarted(.success(makeResponse())), on: state, effect: nil)
    }
    
    // MARK: - prepaymentLoaded
    
    func test_prepaymentLoaded_shouldChangeStateToFailureOnLoadFailureOnEmptyState() {
        
        let emptyState = makeFlow()
        
        assertState(.prepaymentLoaded(.failure), on: emptyState) {
            
            $0.push(.prepayment(.failure))
        }
    }
    
    func test_prepaymentLoaded_shouldNotDeliverEffectOnLoadFailureOnEmptyState() {
        
        let emptyState = makeFlow()
        
        assert(.prepaymentLoaded(.failure), on: emptyState, effect: nil)
    }
    
    func test_prepaymentLoaded_shouldNotChangeStateOnLoadFailureOnNonEmptyState() {
        
        let nonEmptyState = makeSingleDestinationUtilityFlow()
        
        assertState(.prepaymentLoaded(.failure), on: nonEmptyState)
    }
    
    func test_prepaymentLoaded_shouldNotDeliverEffectOnLoadFailureOnNonEmptyState() {
        
        let nonEmptyState = makeSingleDestinationUtilityFlow()
        
        assert(.prepaymentLoaded(.failure), on: nonEmptyState, effect: nil)
    }
    
    func test_prepaymentLoaded_shouldChangeEmptyStateOnLoadSuccess_emptyLastPayments() {
        
        let operators = [makeOperator()]
        let emptyState = makeFlow()
        
        assertState(.prepaymentLoaded(.success([], operators)), on: emptyState) {
            
            $0.push(makePrepayment([], operators))
        }
    }
    
    func test_prepaymentLoaded_shouldNotDeliverEffectOnLoadSuccessOnEmptyState_emptyLastPayments() {
        
        let operators = [makeOperator()]
        let emptyState = makeFlow()
        
        assert(.prepaymentLoaded(.success([], operators)), on: emptyState, effect: nil)
    }
    
    func test_prepaymentLoaded_shouldChangeEmptyStateOnLoadSuccess_nonEmptyLastPayments() {
        
        let (lastPayments, operators) = ([makeLastPayment()], [makeOperator()])
        let emptyState = makeFlow()
        
        assertState(.prepaymentLoaded(.success(lastPayments, operators)), on: emptyState) {
            
            $0.push(makePrepayment(lastPayments, operators))
        }
    }
    
    func test_prepaymentLoaded_shouldNotDeliverEffectOnLoadSuccessOnEmptyState_nonEmptyLastPayments() {
        
        let (lastPayments, operators) = ([makeLastPayment()], [makeOperator()])
        let emptyState = makeFlow()
        
        assert(.prepaymentLoaded(.success(lastPayments, operators)), on: emptyState, effect: nil)
    }
    
    func test_prepaymentLoaded_shouldNotChangeNonEmptyStateOnLoadSuccess() {
        
        let (lastPayments, operators) = ([makeLastPayment()], [makeOperator()])
        let nonEmptyState = makeSingleDestinationUtilityFlow()
        
        assertState(.prepaymentLoaded(.success(lastPayments, operators)), on: nonEmptyState)
    }
    
    func test_prepaymentLoaded_shouldNotDeliverEffectOnLoadSuccessOnNonEmptyState() {
        
        let (lastPayments, operators) = ([makeLastPayment()], [makeOperator()])
        let nonEmptyState = makeSingleDestinationUtilityFlow()
        
        assert(.prepaymentLoaded(.success(lastPayments, operators)), on: nonEmptyState, effect: nil)
    }
    
    // MARK: - PrepaymentOptionsEvent
    
    func test_prepaymentOptionsEvent_shouldNotChangeEmptyFlow_didScrollTo() {
        
        let state = makeEmptyUtilityFlow()
        let event: Event = .prepaymentOptions(.didScrollTo("abc"))
        
        assertState(event, on: state)
        
        XCTAssertNil(state.current)
    }
    
    func test_prepaymentOptionsEvent_shouldNotChangeEmptyFlow_paginatedFailure() {
        
        let state = makeEmptyUtilityFlow()
        let event: Event = .prepaymentOptions(.paginated(.failure(.connectivityError)))
        
        assertState(event, on: state)
        
        XCTAssertNil(state.current)
    }
    
    func test_prepaymentOptionsEvent_shouldNotChangeEmptyFlow_paginatedSuccess() {
        
        let state = makeEmptyUtilityFlow()
        let event: Event = .prepaymentOptions(.paginated(.success([
            makeOperator(), makeOperator()
        ])))
        
        assertState(event, on: state)
        
        XCTAssertNil(state.current)
    }
    
    func test_prepaymentOptionsEvent_shouldNotChangeEmptyFlow_search() {
        
        let state = makeEmptyUtilityFlow()
        let event: Event = .prepaymentOptions(.search(.entered("abc")))
        
        assertState(event, on: state)
        
        XCTAssertNil(state.current)
    }
    
    func test_prepaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_didScrollTo() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeSingleDestinationUtilityFlow(.prepayment(.options(prePaymentOptions)))
        let prepaymentOptionsEvent: PPOEvent = .didScrollTo("abc")
        let (sut, ppoReducer) = makeSUT()
        
        _ = sut.reduce(state, .prepaymentOptions(prepaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prepaymentOptionsEvent])
    }
    
    func test_prepaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_paginated() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeSingleDestinationUtilityFlow(.prepayment(.options(prePaymentOptions)))
        let prepaymentOptionsEvent: PPOEvent = .paginated(
            .failure(.connectivityError)
        )
        let (sut, ppoReducer) = makeSUT()
        
        _ = sut.reduce(state, .prepaymentOptions(prepaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prepaymentOptionsEvent])
    }
    
    func test_prepaymentOptionsEvent_shouldCallPrePaymentOptionsReducerOnPrePaymentOptionsState_search() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeSingleDestinationUtilityFlow(.prepayment(.options(prePaymentOptions)))
        let prepaymentOptionsEvent: PPOEvent = .search(.entered(""))
        let (sut, ppoReducer) = makeSUT()
        
        _ = sut.reduce(state, .prepaymentOptions(prepaymentOptionsEvent))
        
        XCTAssertNoDiff(ppoReducer.messages.map(\.state), [prePaymentOptions])
        XCTAssertNoDiff(ppoReducer.messages.map(\.event), [prepaymentOptionsEvent])
    }
    
    func test_prepaymentOptionsEvent_shouldChangePrePaymentOptionsStateToPrePaymentOptionsReduceResult() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeSingleDestinationUtilityFlow(.prepayment(.options(prePaymentOptions)))
        let event: Event = .prepaymentOptions(.search(.entered("")))
        let (ppoStateStub, ppoEffectStub) = makePPOStub(
            lastPaymentsCount: 1,
            operatorsCount: 3,
            searchText: "abc",
            ppoEffect: .search("abc")
        )
        let (sut, _) = makeSUT(ppoStub: [(ppoStateStub, ppoEffectStub)])
        
        assertState(sut: sut, event, on: state) {
            
            $0 = makeSingleDestinationUtilityFlow(.prepayment(.options(ppoStateStub)))
        }
    }
    
    func test_prepaymentOptionsEvent_shouldDeliverPrePaymentOptionsReduceEffect() {
        
        let prePaymentOptions = makePrePaymentOptionsState()
        let state = makeSingleDestinationUtilityFlow(.prepayment(.options(prePaymentOptions)))
        let event: Event = .prepaymentOptions(.search(.entered("")))
        let ppoStateStub = makePrePaymentOptionsState(
            lastPaymentsCount: 1,
            operatorsCount: 3,
            searchText: "abc"
        )
        let ppoEffectStub: PPOEffect = .search("abc")
        let (sut, _) = makeSUT(ppoStub: [(ppoStateStub, ppoEffectStub)])
        
        assert(sut: sut, event, on: state, effect: .prepaymentOptions(ppoEffectStub))
    }
    
    // MARK: - select
    
    func test_select_lastPayment_shouldNotChangeEmptyState() {
        
        let lastPayment = makeLastPayment()
        let emptyState = makeFlow()
        
        assertState(.select(.last(lastPayment)), on: emptyState)
    }
    
    func test_select_lastPayment_shouldNotDeliverEffectOnEmptyState() {
        
        let lastPayment = makeLastPayment()
        let emptyState = makeFlow()
        
        assert(.select(.last(lastPayment)), on: emptyState, effect: nil)
    }
    
    func test_select_lastPayment_shouldNotChangeTopPrepaymentState() {
        
        let lastPayment = makeLastPayment()
        let topPrepaymentState = makeFlow(makePrepayment([lastPayment], [makeOperator()]))
        
        assertState(.select(.last(lastPayment)), on: topPrepaymentState)
    }
    
    func test_select_lastPayment_shouldDeliverEffectOnTopPrepaymentState() {
        
        let lastPayment = makeLastPayment()
        let topPrepaymentState = makeFlow(makePrepayment([lastPayment], [makeOperator()]))
        
        assert(.select(.last(lastPayment)), on: topPrepaymentState, effect: .select(.last(lastPayment)))
    }
    
    func test_select_lastPayment_shouldNotChangeTopServicesState() {
        
        let lastPayment = makeLastPayment()
        let topServicesState = makeFlow(.services(makeServices()))
        
        assert(.select(.last(lastPayment)), on: topServicesState, effect: nil)
    }
    
    func test_select_lastPayment_shouldNotDeliverEffectOnTopServicesState() {
        
        let lastPayment = makeLastPayment()
        let topServicesState = makeFlow(.services(makeServices()))
        
        assert(.select(.last(lastPayment)), on: topServicesState, effect: nil)
    }
    
    func test_select_operator_shouldNotChangeEmptyState() {
        
        let `operator` = makeOperator()
        let emptyState = makeFlow()
        
        assertState(.select(.operator(`operator`)), on: emptyState)
    }
    
    func test_select_operator_shouldNotDeliverEffectOnEmptyState() {
        
        let `operator` = makeOperator()
        let emptyState = makeFlow()
        
        assert(.select(.operator(`operator`)), on: emptyState, effect: nil)
    }
    
    func test_select_operator_shouldNotChangeTopPrepaymentState() {
        
        let `operator` = makeOperator()
        let topPrepaymentState = makeFlow(makePrepayment([], [makeOperator()]))
        
        assertState(.select(.operator(`operator`)), on: topPrepaymentState)
    }
    
    func test_select_operator_shouldDeliverEffectOnTopPrepaymentState() {
        
        let `operator` = makeOperator()
        let topPrepaymentState = makeFlow(makePrepayment([], [makeOperator()]))
        
        assert(.select(.operator(`operator`)), on: topPrepaymentState, effect: .select(.operator(`operator`)))
    }
    
    func test_select_operator_shouldNotChangeTopServicesState() {
        
        let `operator` = makeOperator()
        let topServicesState = makeFlow(.services(makeServices()))
        
        assert(.select(.operator(`operator`)), on: topServicesState, effect: nil)
    }
    
    func test_select_operator_shouldNotDeliverEffectOnTopServicesState() {
        
        let `operator` = makeOperator()
        let topServicesState = makeFlow(.services(makeServices()))
        
        assert(.select(.operator(`operator`)), on: topServicesState, effect: nil)
    }
    
    // MARK: - selectFailure
    
    func test_selectFailure_shouldPushFailureDestinationOnTop() {
        
        let state = makeFlow()
        let `operator` = makeOperator()
        
        assertState(.selectFailure(`operator`), on: state) {
            
            $0.push(.selectFailure(`operator`))
        }
    }
    
    func test_selectFailure_shouldNotDeliverEffect() {
        
        let state = makeFlow()
        let `operator` = makeOperator()
        
        assert(.selectFailure(`operator`), on: state, effect: nil)
    }
    
    func test_select_service_shouldNotChangePrepaymentState() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let prepaymentState = makeFlow(makePrepayment())
        
        assertState(.select(.service(service, for: `operator`)), on: prepaymentState)
    }
    
    func test_select_service_shouldNotDeliverEffectOnPrepaymentState() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let prepaymentState = makeFlow(makePrepayment())
        
        assert(.select(.service(service, for: `operator`)), on: prepaymentState, effect: nil)
    }
    
    func test_select_service_shouldNotChangeServicesState() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let topServicesState = makeFlow(.services([service, makeService()]))
        
        assertState(.select(.service(service, for: `operator`)), on: topServicesState)
    }
    
    func test_select_service_shouldDeliverEffectOnServicesState() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let topServicesState = makeFlow(.services([service, makeService()]))
        
        assert(
            .select(.service(service, for: `operator`)),
            on: topServicesState,
            effect: .select(.service(service, for: `operator`))
        )
    }
    
    // MARK: - servicesLoaded
    
    func test_loadedServices_shouldPushServicesDestinationOnTop() {
        
        let state = makeFlow()
        let services = makeServices()
        
        assertState(.servicesLoaded(services), on: state) {
            
            $0.push(.services(services))
        }
    }
    
    func test_loadedServices_shouldNotDeliverEffect() {
        
        let state = makeFlow()
        let services = makeServices()
        
        assert(.servicesLoaded(services), on: state, effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityReducer
    
    private typealias State = UtilityFlow
    private typealias Event = UtilityEvent
    private typealias Effect = UtilityEffect
    
    private typealias PPOReducer = ReducerSpy<PPOState, PPOEvent, PPOEffect>
    
    private func makeSUT(
        ppoStub: [(PPOState, PPOEffect?)] = [makePPOStub()],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        ppoReducer: PPOReducer
    ) {
        let ppoReducer = PPOReducer(stub: ppoStub)
        let sut = SUT(ppoReduce: ppoReducer.reduce(_:_:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(ppoReducer, file: file, line: line)
        
        return (sut, ppoReducer)
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
        let sut = sut ?? makeSUT().sut
        
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
        let sut = sut ?? makeSUT().sut
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
    }
}
