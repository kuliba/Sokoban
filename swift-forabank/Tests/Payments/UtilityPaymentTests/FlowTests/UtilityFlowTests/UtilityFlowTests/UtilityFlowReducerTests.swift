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
        
        assert(.select(.last(lastPayment)), on: topPrepaymentState, effect: .select(.last(lastPayment)))
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
        
        assert(.select(.operator(`operator`)), on: topPrepaymentState, effect: .select(.operator(`operator`)))
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
    
    private typealias SUT = UtilityFlowReducer<LastPayment, Operator, UtilityService, StartPaymentResponse>
    
    private typealias Destination = UtilityDestination<LastPayment, Operator>
    
    private typealias State = Flow<Destination>
    private typealias Event = UtilityFlowEvent<LastPayment, Operator, UtilityService, StartPaymentResponse>
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
