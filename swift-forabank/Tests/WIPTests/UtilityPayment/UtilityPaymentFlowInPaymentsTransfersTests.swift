//
//  UtilityPaymentFlowInPaymentsTransfersTests.swift
//  
//
//  Created by Igor Malyarov on 13.03.2024.
//

import UtilityPayment
import XCTest

struct PaymentsTransfersState: Equatable {
    
    var destination: Destination?
}

extension PaymentsTransfersState {
    
    enum Destination: Equatable {
        
        case utilityFlow(UtilityFlow)
    }
    
    typealias UtilityFlow = UtilityPaymentFlowState<LastPayment, Operator, UtilityService>
}

enum PaymentsTransfersEvent: Equatable {
    
    case openUtilityPayment
}

final class PaymentsTransfersReducer {
    
    private let spinnerHandler: SpinnerHandler
    
    init(spinnerHandler: @escaping SpinnerHandler) {
        
        self.spinnerHandler = spinnerHandler
    }
}

extension PaymentsTransfersReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        return (state, effect)
    }
}

extension PaymentsTransfersReducer {
    
    typealias SpinnerHandler = (Bool) -> Void
    
    typealias State = PaymentsTransfersState
    typealias Event = PaymentsTransfersEvent
    typealias Effect = Never//PaymentsTransfersEffect
}

final class UtilityPaymentFlowInPaymentsTransfersTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
    }
    
//    func test_openUtilityPayment_shouldNotChangeNilRouteState() {
//        
//        assertState(.openUtilityPayment, on: .init(route: nil))
//    }
//    
//    func test_openUtilityPayment_shouldDeliverEffectOnNilRouteState() {
//        
//        assert(.openUtilityPayment, on: .init(route: nil), effect: .open)
//    }
//    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersReducer
    private typealias SpinnerSpy = CallSpy<Bool>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: SpinnerSpy
    ) {
        let spy = SpinnerSpy()
        let sut = SUT(spinnerHandler: spy.call(payload:))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
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
