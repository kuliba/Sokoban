//
//  PaymentReducerTests.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

struct PaymentState<Payment, DocumentStatus, OperationDetails> {
    
    var payment: Payment
    var status: Status?
}

extension PaymentState {
    
    enum Status {
        
        case result(Result<Report, Terminated>)
        case serverError(String)
    }
}

extension PaymentState.Status {
    
    enum Terminated: Error {
        
        case transactionFailure
        case updateFailure
    }
}

extension PaymentState.Status {
    
    typealias Report = TransactionReport<DocumentStatus, OperationDetails>
}

extension PaymentState: Equatable where Payment: Equatable, DocumentStatus: Equatable, OperationDetails: Equatable {}
extension PaymentState.Status: Equatable where DocumentStatus: Equatable, OperationDetails: Equatable {}

final class PaymentReducer<Digest, DocumentStatus, OperationDetails, Payment, Update> {
    
    private let updatePayment: UpdatePayment
    
    init(updatePayment: @escaping UpdatePayment) {
        
        self.updatePayment = updatePayment
    }
}

extension PaymentReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .completePayment(transactionResult):
            reduce(&state, with: transactionResult)
            
        case let .update(updateResult):
            reduce(&state, with: updateResult)
        }
        
        return (state, effect)
    }
}

extension PaymentReducer {
    
    typealias UpdatePayment = (Payment, Update) -> Payment
    
    typealias State = PaymentState<Payment, DocumentStatus, OperationDetails>
    typealias Event = PaymentEvent<DocumentStatus, OperationDetails, Update>
    typealias Effect = PaymentEffect<Digest>
}

private extension PaymentReducer {
    
    func reduce(
        _ state: inout State,
        with transactionResult: Event.TransactionResult
    ) {
        switch transactionResult {
        case .none:
            state.status = .result(.failure(.transactionFailure))
            
        case let .some(report):
            state.status = .result(.success(report))
        }
    }
    
    func reduce(
        _ state: inout State,
        with updateResult: Event.UpdateResult
    ) {
        switch updateResult {
        case let .failure(serviceFailure):
            switch serviceFailure {
            case .connectivityError:
                state.status = .result(.failure(.updateFailure))
                
            case let .serverError(message):
                state.status = .serverError(message)
            }
            
        case let .success(update):
            state.payment = updatePayment(state.payment, update)
        }
    }
}

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
    
    private typealias SUT = PaymentReducer<Digest, DocumentStatus, OperationDetails, SimplePayment, Update>
    
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias Payment = SimplePayment
    
    private func makeSUT(
        updatePayment: @escaping ((Payment, Update) -> Payment) = { payment, _ in payment },
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(updatePayment: updatePayment)
        
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
