//
//  PaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

struct PaymentState: Equatable {
    
    var status: Status?
}

extension PaymentState {
    
    enum Status: Equatable {
        
        case completed(Completed)
        case serverError(String)
    }
}

extension PaymentState.Status {
    
    enum Completed: Equatable {
        
        case terminated
    }
}

final class PaymentReducer<Digest, DocumentStatus, OperationDetails, Update> {}

extension PaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .update(updateResult):
            reduce(&state, with: updateResult)
            
        default:
            break
        }
        
        return (state, effect)
        
    }
}

extension PaymentReducer {
    
    typealias State = PaymentState
    typealias Event = PaymentEvent<DocumentStatus, OperationDetails, Update>
    typealias Effect = PaymentEffect<Digest>
}

private extension PaymentReducer {
    
    func reduce(
        _ state: inout State,
        with updateResult: Event.UpdateResult
    ) {
        switch updateResult {
        case let .failure(serviceFailure):
            switch serviceFailure {
            case .connectivityError:
                state.status = .completed(.terminated)
                
            case let .serverError(message):
                state.status = .serverError(message)
            }
            
        case let .success(update):
            break
        }
    }
}

import AnywayPaymentCore
import XCTest

final class PaymentReducerTests: XCTestCase {
    
    // MARK: - completePayment
    
    func test_completePayment_shouldNotDeliverEffectOnReportFailure() {
        
        assert(.completePayment(nil), on: makePaymentState(), effect: nil)
    }
    
    func test_completePayment_shouldNotDeliverEffectOnDetailIDReport() {
        
        assert(completePaymentReportEvent(makeDetailIDTransactionReport()), on: makePaymentState(), effect: nil)
    }
    
    func test_completePayment_shouldNotDeliverEffectOnOperationDetailsReport() {
        
        assert(completePaymentReportEvent(makeDetailIDTransactionReport()), on: makePaymentState(), effect: nil)
    }
    
    // MARK: - update
    
    func test_update_shouldChangeStatusToTerminatedOnConnectivityErrorFailure() {
        
        let state = makePaymentState()
        
        assertState(makeUpdateFailureEvent(), on: state) {
            
            $0.status = .completed(.terminated)
        }
    }
    
    func test_update_shouldChangeStatusToServerErrorOnServerErrorFailure() {
        
        let message = anyMessage()
        let state = makePaymentState()
        
        assertState(makeUpdateFailureEvent(message), on: state) {
            
            $0.status = .serverError(message)
        }
    }
    
    func test_update_shouldNotDeliverEffectOnConnectivityErrorFailure() {
        
        assert(makeUpdateFailureEvent(), on: makePaymentState(), effect: nil)
    }
    
    func test_update_shouldNotDeliverEffectOnServerErrorFailure() {
        
        assert(makeUpdateFailureEvent(anyMessage()), on: makePaymentState(), effect: nil)
    }
    
    func test_update_shouldNotDeliverEffectOnUpdate() {
        
        assert(makeUpdateEvent(), on: makePaymentState(), effect: nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentReducer<Digest, DocumentStatus, OperationDetails, Update>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
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
