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
    
    // MARK: - loaded
    
    func test_loaded_shouldChangeStateToFailureOnLoadFailureOnEmptyState() {
        
        let emptyState = makeFlow()
        
        assertState(.loaded(.failure), on: emptyState) {
            
            $0.push(.prepayment(.failure))
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadFailureOnEmptyState() {
        
        let emptyState = makeFlow()
        
        assert(.loaded(.failure), on: emptyState, effect: nil)
    }
    
    func test_loaded_shouldNotChangeStateOnLoadFailureOnNonEmptyState() {
        
        let nonEmptyState = makeSingleDestinationUtilityFlow()
        
        assertState(.loaded(.failure), on: nonEmptyState)
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadFailureOnNonEmptyState() {
        
        let nonEmptyState = makeSingleDestinationUtilityFlow()
        
        assert(.loaded(.failure), on: nonEmptyState, effect: nil)
    }
    
    func test_loaded_shouldChangeEmptyStateOnLoadSuccess_emptyLastPayments() {
        
        let operators = [makeOperator()]
        let emptyState = makeFlow()
        
        assertState(.loaded(.success([], operators)), on: emptyState) {
            
            $0.push(makePrepayment([], operators))
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadSuccessOnEmptyState_emptyLastPayments() {
        
        let operators = [makeOperator()]
        let emptyState = makeFlow()
        
        assert(.loaded(.success([], operators)), on: emptyState, effect: nil)
    }
    
    func test_loaded_shouldChangeEmptyStateOnLoadSuccess_nonEmptyLastPayments() {
        
        let (lastPayments, operators) = ([makeLastPayment()], [makeOperator()])
        let emptyState = makeFlow()
        
        assertState(.loaded(.success(lastPayments, operators)), on: emptyState) {
            
            $0.push(makePrepayment(lastPayments, operators))
        }
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadSuccessOnEmptyState_nonEmptyLastPayments() {
        
        let (lastPayments, operators) = ([makeLastPayment()], [makeOperator()])
        let emptyState = makeFlow()
        
        assert(.loaded(.success(lastPayments, operators)), on: emptyState, effect: nil)
    }
    
    func test_loaded_shouldNotChangeNonEmptyStateOnLoadSuccess() {
        
        let (lastPayments, operators) = ([makeLastPayment()], [makeOperator()])
        let nonEmptyState = makeSingleDestinationUtilityFlow()
        
        assertState(.loaded(.success(lastPayments, operators)), on: nonEmptyState)
    }
    
    func test_loaded_shouldNotDeliverEffectOnLoadSuccessOnNonEmptyState() {
        
        let (lastPayments, operators) = ([makeLastPayment()], [makeOperator()])
        let nonEmptyState = makeSingleDestinationUtilityFlow()
        
        assert(.loaded(.success(lastPayments, operators)), on: nonEmptyState, effect: nil)
    }
    
    // MARK: - loadedServices
    
    func test_loadedServices_shouldPushServicesDestinationOnTop() {
        
        let state = makeFlow()
        let services = makeServices()
        
        assertState(.loadedServices(services), on: state) {
            
            $0.push(.services(services))
        }
    }
    
    func test_loadedServices_shouldNotDeliverEffect() {
        
        let state = makeFlow()
        let services = makeServices()
        
        assert(.loadedServices(services), on: state, effect: nil)
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
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityFlowReducer<LastPayment, Operator, Service, StartPaymentResponse>
    
    private typealias State = UtilityFlow
    private typealias Event = UtilityEvent
    private typealias Effect = UtilityEffect
    
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
