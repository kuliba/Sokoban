//
//  PaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

import AnywayPaymentCore
import XCTest

final class PaymentReducerTests: XCTestCase {
    
    // MARK: - completePayment
    
    func test_completePayment_shouldChangeStatusToTerminatedTransactionFailureOnReportFailure() {
        
        assertState(.completePayment(nil), on: makePaymentState()) {
            
            $0.status = .result(.failure(.transactionFailure))
        }
    }
    
    func test_completePayment_shouldChangeStatusToProcessedDetailIDTransactionReport() {
        
        let report = makeDetailIDTransactionReport()
        
        assertState(.completePayment(report), on: makePaymentState()) {
            
            $0.status = .result(.success(report))
        }
    }
    
    func test_completePayment_shouldChangeStatusToProcessedOperationDetailsTransactionReport() {
        
        let report = makeOperationDetailsTransactionReport()
        
        assertState(.completePayment(report), on: makePaymentState()) {
            
            $0.status = .result(.success(report))
        }
    }
    
    func test_completePayment_shouldNotDeliverEffectOnReportFailure() {
        
        assert(.completePayment(nil), on: makePaymentState(), effect: nil)
    }
    
    func test_completePayment_shouldNotDeliverEffectOnDetailIDReport() {
        
        assert(completePaymentReportEvent(makeDetailIDTransactionReport()), on: makePaymentState(), effect: nil)
    }
    
    func test_completePayment_shouldNotDeliverEffectOnOperationDetailsReport() {
        
        assert(completePaymentReportEvent(makeDetailIDTransactionReport()), on: makePaymentState(), effect: nil)
    }
    
    // MARK: - parameter (or field) event
    
    func test_parameter_shouldCallParameterReduceWithPaymentAndEvent() {
        
        let (payment, event) = (makePayment(), makeParameterEvent())
        var payloads = [(payment: Payment, event: ParameterEvent)]()
        let sut = makeSUT(
            parameterReduce: { payment, event in
                
                payloads.append((payment, event))
                return (payment, nil)
            }
        )
        
        _ = sut.reduce(makePaymentState(payment), .parameter(event))
        
        XCTAssertNoDiff(payloads.map(\.payment), [payment])
        XCTAssertNoDiff(payloads.map(\.event), [event])
    }
    
    func test_parameter_shouldSetPaymentToParameterReducePayment() {
        
        let (payment, event) = (makePayment(), makeParameterEvent())
        let newPayment = makePayment()
        let sut = makeSUT(
            parameterReduce: { _,_ in (newPayment, nil) }
        )
        
        assertState(sut: sut, .parameter(event), on: makePaymentState(payment)) {
            
            $0.payment = newPayment
        }
    }
    
    func test_parameter_shouldSetEffectToParameterReduceEffect() {
        
        let (payment, event) = (makePayment(), makeParameterEvent())
        let effect = makeParameterPaymentEffect()
        let sut = makeSUT(
            parameterReduce: { _,_ in (makePayment(), effect) }
        )
        
        assert(sut: sut, .parameter(event), on: makePaymentState(payment), effect: effect)
    }
    
    // MARK: - update
    
    func test_update_shouldChangeStatusToTerminatedUpdateFailureOnConnectivityErrorFailure() {
        
        assertState(makeUpdateFailureEvent(), on: makePaymentState()) {
            
            $0.status = .result(.failure(.updateFailure))
        }
    }
    
    func test_update_shouldChangeStatusToServerErrorOnServerErrorFailure() {
        
        let message = anyMessage()
        
        assertState(makeUpdateFailureEvent(message), on: makePaymentState()) {
            
            $0.status = .serverError(message)
        }
    }
    
    func test_update_shouldCallUpdateWithPaymentAndUpdate() {
        
        let payment = makePayment()
        let update = makeUpdate()
        var updatePayloads = [(payment: Payment, update: Update)]()
        let sut = makeSUT(updatePayment: {
            
            updatePayloads.append(($0, $1))
            return $0
        })
        
        _ = sut.reduce(makePaymentState(payment), makeUpdateEvent(update))
        
        XCTAssertNoDiff(updatePayloads.map(\.payment), [payment])
        XCTAssertNoDiff(updatePayloads.map(\.update), [update])
    }
    
    func test_update_shouldSetPaymentToUpdatedValue() {
        
        let payment = makePayment()
        let updatedPayment = makePayment()
        let sut = makeSUT(updatePayment: { _, _ in updatedPayment })
        
        assertState(sut: sut, makeUpdateEvent(makeUpdate()), on: makePaymentState(payment)) {
            
            $0.payment = updatedPayment
        }
        XCTAssertNotEqual(payment, updatedPayment)
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
    
    private typealias SUT = PaymentReducer<Digest, DocumentStatus, OperationDetails, ParameterEffect, Payment, Update>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private func makeSUT(
        parameterReduce: @escaping (Payment, ParameterEvent) -> (Payment, Effect?) = { payment, _ in (payment, nil) },
        updatePayment: @escaping ((Payment, Update) -> Payment) = { payment, _ in payment },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            parameterReduce: parameterReduce,
            updatePayment: updatePayment
        )
        
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
