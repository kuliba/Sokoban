//
//  ServicePaymentFlowReducerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.07.2024.
//

@testable import AnywayPaymentDomain
@testable import ForaBank
import XCTest

final class ServicePaymentFlowReducerTests: XCTestCase {
    
    // MARK: - notify
    
    func test_notify_shouldSetModalToNilOnNilStatus() {
        
        assert(
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(nil)
        ) {
            $0.modal = nil
        }
    }
#warning("add effect assertion test")
    
    func test_notify_shouldSetAlertOnAwaitingPaymentRestartConfirmation() {
        
        assert(
            makeState(modal: nil),
            event: .notify(.awaitingPaymentRestartConfirmation)
        ) {
            $0.modal = .alert(.paymentRestartConfirmation)
        }
    }
#warning("add effect assertion test")
    func test_notify_shouldNotChangeStateOnMakeFraudFailure() {
        
        let sut = makeSUT(fraud: nil)
        
        assert(
            sut: sut,
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(.fraudSuspected(makePaymentUpdate()))
        )
    }
#warning("add effect assertion test")
    
    func test_notify_shouldSetFraudOnMakeFraud() {
        
        let fraud = makeFraud()
        let sut = makeSUT(fraud: fraud)
        
        assert(
            sut: sut,
            makeState(modal: nil),
            event: .notify(.fraudSuspected(makePaymentUpdate()))
        ) {
            $0.modal = .fraud(fraud)
        }
    }
#warning("add effect assertion test")
    
    func test_notify_shouldNotChangeStateOnOInflight() {
        
        assert(
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(.inflight)
        )
    }
#warning("add effect assertion test")
    
    func test_notify_shouldSetAlertOnServerError() {
        
        let errorMessage = anyMessage()
        
        assert(
            makeState(modal: nil),
            event: .notify(.serverError(errorMessage))
        ) {
            $0.modal = .alert(.serverError(errorMessage))
        }
    }
#warning("add effect assertion test")
    
    func test_notify_shouldResetModalOnFraudCancelledTerminated() {
        
        assert(
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(.result(.failure(.fraud(.cancelled))))
        ) {
            $0.modal = nil
        }
    }
    
    func test_notify_shouldDeliverEffectOnFraudCancelledTerminated() {
        
        let formattedAmount = anyMessage()
        let sut = makeSUT(formattedAmount: formattedAmount)
        
        assert(
            sut: sut,
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(.result(.failure(.fraud(.cancelled)))),
            delivers: .delay(
                .showResult(.failure(.init(
                    formattedAmount: formattedAmount,
                    hasExpired: false
                ))),
                for: .milliseconds(300)
            )
        )
    }
    
    func test_notify_shouldResetModalOnFraudExpiredTerminated() {
        
        assert(
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(.result(.failure(.fraud(.expired))))
        ) {
            $0.modal = nil
        }
    }
    
    func test_notify_shouldDeliverEffectOnFraudExpiredTerminated() {
        
        let formattedAmount = anyMessage()
        let sut = makeSUT(formattedAmount: formattedAmount)
        
        assert(
            sut: sut,
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(.result(.failure(.fraud(.expired)))),
            delivers: .delay(
                .showResult(.failure(.init(
                    formattedAmount: formattedAmount,
                    hasExpired: true
                ))),
                for: .milliseconds(300)
            )
        )
    }
    
    func test_notify_shouldSetAlertOnTransactionFailure() {
        
        assert(
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(.result(.failure(.transactionFailure)))
        ) {
            $0.modal = .alert(.terminalError("Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже."))
        }
    }
    
    func test_notify_shouldNotDeliverEffectOnTransactionFailure() {
        
        assert(
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(.result(.failure(.transactionFailure))),
            delivers: nil
        )
    }
    
    func test_notify_shouldSetAlertOnUpdatePaymentFailure() {
        
        assert(
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(.result(.failure(.updatePaymentFailure)))
        ) {
            $0.modal = .alert(.serverError("Error"))
        }
    }
    
    func test_notify_shouldNotDeliverEffectOnUpdatePaymentFailure() {
        
        assert(
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(.result(.failure(.updatePaymentFailure))),
            delivers: nil
        )
    }
    
    func test_notify_shouldResetModalOnSuccess() {
        
        assert(
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(.result(.success(makeReport())))
        ) {
            $0.modal = nil
        }
    }
    
    func test_notify_shouldDeliverEffectOnSuccess() {
        
        let report = makeReport()
        
        assert(
            makeState(modal: .alert(.paymentRestartConfirmation)),
            event: .notify(.result(.success(report))),
            delivers: .delay(
                .showResult(.success(report)),
                for: .milliseconds(300)
            )
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = ServicePaymentFlowReducer
    
    private func makeSUT(
        formattedAmount: String = anyMessage(),
        fraud: FraudNoticePayload? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            factory: .init(
                getFormattedAmount: { _ in formattedAmount },
                makeFraud: { _ in fraud }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func makeState(
        modal: SUT.State.Modal?
    ) -> SUT.State {
        
        return .init(modal: modal)
    }
    
    private func makeFraud(
        title: String = anyMessage(),
        subtitle: String? = anyMessage(),
        formattedAmount: String = anyMessage(),
        delay: Double = .random(in: 1...100)
    ) -> FraudNoticePayload {
        
        return .init(title: title, subtitle: subtitle, formattedAmount: formattedAmount, delay: delay)
    }
    
    private func makePaymentUpdate() -> AnywayPaymentUpdate {
        
        return .init(
            details: .init(
                amounts: .init(amount: nil, creditAmount: nil, currencyAmount: nil, currencyPayee: nil, currencyPayer: nil, currencyRate: nil, debitAmount: nil, fee: nil),
                control: .init(isFinalStep: false, isFraudSuspected: false, isMultiSum: false, needOTP: false, needSum: false),
                info: .init(documentStatus: nil, infoMessage: nil, payeeName: nil, paymentOperationDetailID: nil, printFormType: nil)
            ),
            fields: [],
            parameters: []
        )
    }
    
    private func makeReport(
        status: DocumentStatus = .completed,
        info: _OperationInfo = .detailID(.random(in: 1...100))
    ) -> AnywayTransactionReport {
        
        return .init(status: status, info: info)
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        updateStateToExpected: ((inout SUT.State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.State {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        var expectedState = state
        updateStateToExpected?(&expectedState)
        
        let (receivedState, _) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedState,
            expectedState,
            "\nExpected \(String(describing: expectedState)), but got \(String(describing: receivedState)) instead.",
            file: file, line: line
        )
        
        return receivedState
    }
    
    @discardableResult
    private func assert(
        sut: SUT? = nil,
        _ state: SUT.State,
        event: SUT.Event,
        delivers expectedEffect: SUT.Effect?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT.Effect? {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        
        let (_, receivedEffect) = sut.reduce(state, event)
        
        XCTAssertNoDiff(
            receivedEffect,
            expectedEffect,
            "\nExpected \(String(describing: expectedEffect)), but got \(String(describing: receivedEffect)) instead.",
            file: file, line: line
        )
        
        return receivedEffect
    }
}
