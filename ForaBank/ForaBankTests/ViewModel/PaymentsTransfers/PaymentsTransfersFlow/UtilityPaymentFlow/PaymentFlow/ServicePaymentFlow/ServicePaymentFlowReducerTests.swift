//
//  ServicePaymentFlowReducerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 25.07.2024.
//

import AnywayPaymentDomain
@testable import ForaBank
import XCTest

final class ServicePaymentFlowReducerTests: ServicePaymentFlowTests {
    
    // MARK: - terminate
    
    func test_terminate_shouldSetNoneStateToTerminated() {
        
        assert(.none, event: .terminate) {
            
            $0 = .terminated
        }
    }
    
    func test_dismissModal_shouldNotDeliverEffectOnNoneState() {
        
        assert(.none, event: .terminate, delivers: nil)
    }
    
    func test_terminate_shouldSetAlertStateToTerminated() {
        
        assert(.alert(.paymentRestartConfirmation), event: .terminate) {
            
            $0 = .terminated
        }
    }
    
    func test_dismissModal_shouldNotDeliverEffectOnAlertState() {
        
        assert(.alert(.paymentRestartConfirmation), event: .terminate, delivers: nil)
    }
    
    func test_terminate_shouldSetFraudStateToTerminated() {
        
        assert(.fraud(makeFraudPayload()), event: .terminate) {
            
            $0 = .terminated
        }
    }
    
    func test_dismissModal_shouldNotDeliverEffectOnFraudState() {
        
        assert(.fraud(makeFraudPayload()), event: .terminate, delivers: nil)
    }
    
    func test_terminate_shouldSetFullScreenCoverStateToTerminated() {
        
        assert(.fullScreenCover(.completed(.success(makeReport()))), event: .terminate) {
            
            $0 = .terminated
        }
    }
    
    func test_dismissModal_shouldNotDeliverEffectOnFullScreenCoverState() {
        
        assert(.fullScreenCover(.completed(.success(makeReport()))), event: .terminate, delivers: nil)
    }
    
    // MARK: - notify
    
    func test_notify_shouldSetModalToNilOnNilStatus() {
        
        assert(
            makeState(alert: .paymentRestartConfirmation),
            event: notify(nil)
        ) {
            $0 = .none
        }
    }
    
    func test_notify_shouldNotDeliverEffectOnNilStatus() {
        
        assert(
            makeState(alert: .paymentRestartConfirmation),
            event: notify(nil),
            delivers: nil
        )
    }
    
    func test_notify_shouldSetAlertOnAwaitingPaymentRestartConfirmation() {
        
        assert(
            .none,
            event: notify(.awaitingPaymentRestartConfirmation)
        ) {
            $0 = .alert(.paymentRestartConfirmation)
        }
    }
    
    func test_notify_shouldNotDeliverEffectOnAwaitingPaymentRestartConfirmation() {
        
        assert(
            .none,
            event: notify(.awaitingPaymentRestartConfirmation),
            delivers: nil
        )
    }
    
    func test_notify_shouldNotChangeStateOnMakeFraudFailure() {
        
        let sut = makeSUT(fraud: nil)
        
        assert(
            sut: sut,
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.fraudSuspected(makePaymentUpdate()))
        )
    }
    
    func test_notify_shouldNotDeliverEffectOnMakeFraudFailure() {
        
        let sut = makeSUT(fraud: nil)
        
        assert(
            sut: sut,
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.fraudSuspected(makePaymentUpdate())),
            delivers: nil
        )
    }
    
    func test_notify_shouldSetFraudOnMakeFraud() {
        
        let fraud = makeFraudPayload()
        let sut = makeSUT(fraud: fraud)
        
        assert(
            sut: sut,
            .none,
            event: notify(.fraudSuspected(makePaymentUpdate()))
        ) {
            $0 = .fraud(fraud)
        }
    }
    
    func test_notify_shouldNotDeliverEffectOnMakeFraud() {
        
        let fraud = makeFraudPayload()
        let sut = makeSUT(fraud: fraud)
        
        assert(
            sut: sut,
            .none,
            event: notify(.fraudSuspected(makePaymentUpdate())),
            delivers: nil
        )
    }
    
    func test_notify_shouldNotChangeStateOnOInflight() {
        
        assert(
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.inflight)
        )
    }
    
    func test_notify_shouldNotDeliverEffectOnOInflight() {
        
        assert(
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.inflight),
            delivers: nil
        )
    }
    
    func test_notify_shouldSetAlertOnServerError() {
        
        let errorMessage = anyMessage()
        
        assert(
            .none,
            event: notify(.serverError(errorMessage))
        ) {
            $0 = .alert(.serverError(errorMessage))
        }
    }
    
    func test_notify_shouldNotDeliverEffectOnServerError() {
        
        let errorMessage = anyMessage()
        
        assert(
            .none,
            event: notify(.serverError(errorMessage)),
            delivers: nil
        )
    }
    
    func test_notify_shouldResetModalOnFraudCancelledTerminated() {
        
        assert(
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.result(.failure(.fraud(.cancelled))))
        ) {
            $0 = .none
        }
    }
    
    func test_notify_shouldDeliverEffectOnFraudCancelledTerminated() {
        
        let formattedAmount = anyMessage()
        let sut = makeSUT(formattedAmount: formattedAmount)
        
        assert(
            sut: sut,
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.result(.failure(.fraud(.cancelled)))),
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
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.result(.failure(.fraud(.expired))))
        ) {
            $0 = .none
        }
    }
    
    func test_notify_shouldDeliverEffectOnFraudExpiredTerminated() {
        
        let formattedAmount = anyMessage()
        let sut = makeSUT(formattedAmount: formattedAmount)
        
        assert(
            sut: sut,
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.result(.failure(.fraud(.expired)))),
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
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.result(.failure(.transactionFailure)))
        ) {
            $0 = .alert(.terminalError("Во время проведения платежа произошла ошибка.\nПопробуйте повторить операцию позже."))
        }
    }
    
    func test_notify_shouldNotDeliverEffectOnTransactionFailure() {
        
        assert(
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.result(.failure(.transactionFailure))),
            delivers: nil
        )
    }
    
    func test_notify_shouldSetAlertOnUpdatePaymentFailure() {
        
        assert(
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.result(.failure(.updatePaymentFailure)))
        ) {
            $0 = .alert(.serverError("Error"))
        }
    }
    
    func test_notify_shouldNotDeliverEffectOnUpdatePaymentFailure() {
        
        assert(
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.result(.failure(.updatePaymentFailure))),
            delivers: nil
        )
    }
    
    func test_notify_shouldResetModalOnSuccess() {
        
        assert(
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.result(.success(makeReport())))
        ) {
            $0 = .none
        }
    }
    
    func test_notify_shouldDeliverEffectOnSuccess() {
        
        let report = makeReport()
        
        assert(
            makeState(alert: .paymentRestartConfirmation),
            event: notify(.result(.success(report))),
            delivers: .delay(
                .showResult(.success(report)),
                for: .milliseconds(300)
            )
        )
    }
    
    // MARK: - showResult
    
    func test_showResult_shouldSetStateToFullScreenCoverFailureOnNonExpiredFraud() {
        
        let nonExpiredFraud = makeFraud(hasExpired: true)
        
        assert(.none, event: .showResult(.failure(nonExpiredFraud))) {
            
            $0 = .fullScreenCover(.completed(.failure(.init(
                formattedAmount: nonExpiredFraud.formattedAmount,
                hasExpired: nonExpiredFraud.hasExpired
            ))))
        }
    }
    
    func test_showResult_shouldNOtDeliverEffectOnNonExpiredFraud() {
        
        let nonExpiredFraud = makeFraud(hasExpired: true)
        
        assert(.none, event: .showResult(.failure(nonExpiredFraud)), delivers: nil)
    }
    
    func test_showResult_shouldSetStateToFullScreenCoverFailureOnExpiredFraud() {
        
        let expiredFraud = makeFraud(hasExpired: false)
        
        assert(.none, event: .showResult(.failure(expiredFraud))) {
            
            $0 = .fullScreenCover(.completed(.failure(.init(
                formattedAmount: expiredFraud.formattedAmount,
                hasExpired: expiredFraud.hasExpired
            ))))
        }
    }
    
    func test_showResult_shouldNOtDeliverEffectOnExpiredFraud() {
        
        let expiredFraud = makeFraud(hasExpired: false)
        
        assert(.none, event: .showResult(.failure(expiredFraud)), delivers: nil)
    }
    
    func test_showResult_shouldSetStateToFullScreenCoverSuccessOnSuccess() {
        
        let report = makeReport()
        
        assert(.none, event: .showResult(.success(report))) {
            
            $0 = .fullScreenCover(.completed(.success(report)))
        }
    }
    
    func test_showResult_shouldNOtDeliverEffectOnSuccess() {
        
        let report = makeReport()
        
        assert(.none, event: .showResult(.success(report)), delivers: nil)
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
                makeFraudNoticePayload: { _ in fraud }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
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
