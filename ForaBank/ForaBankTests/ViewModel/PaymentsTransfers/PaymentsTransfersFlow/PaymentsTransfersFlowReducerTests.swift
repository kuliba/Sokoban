//
//  PaymentsTransfersFlowReducerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.07.2024.
//

@testable import ForaBank
import XCTest

final class PaymentsTransfersFlowReducerTests: XCTestCase {
    
    func test_reduce_shouldCallPaymentTriggerReduceOnPaymentTriggerEvent() {
        
        let latestPayment = makeLatestPayment()
        let event = PaymentTriggerEvent.latestPayment(latestPayment)
        let (sut, spy) = makeSUT(stubs: [makePaymentTriggerState()])
        
        _ = sut.reduce(makeState(), .paymentTrigger(event))
        
        XCTAssertNoDiff(spy.payloads, [event])
    }
    
    func test_reduce_shouldSetNilLegacyStateOnV1() {
        
        let latestPayment = makeLatestPayment()
        let event = PaymentTriggerEvent.latestPayment(latestPayment)
        let (sut, _) = makeSUT(stubs: [.v1])
        
        let reduced = sut.reduce(makeState(), .paymentTrigger(event))
        
        XCTAssertNoDiff(reduced.0.legacy, nil)
        XCTAssertNil(reduced.1)
    }
    
    func test_reduce_shouldSetLegacyStateOnLegacy() {
        
        let latestPayment = makeLatestPayment()
        let paymentTriggerState = makeLegacyPaymentTriggerState(.latestPayment(latestPayment))
        let event = PaymentTriggerEvent.latestPayment(latestPayment)
        let (sut, _) = makeSUT(stubs: [paymentTriggerState])
        
        let reduced = sut.reduce(makeState(), .paymentTrigger(event))
        
        XCTAssertNoDiff(reduced.0.legacy, .latestPayment(latestPayment))
        XCTAssertNil(reduced.1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentsTransfersFlowReducer
    private typealias Factory = PaymentsTransfersFlowReducerFactory
    
    private typealias PaymentTriggerSpy = CallSpy<PaymentTriggerEvent, PaymentTriggerState>
    
    private typealias LastPayment = String
    private typealias Operator = String
    private typealias Service = String
    private typealias Content = String
    private typealias PaymentViewModel = String
    
    private func makeSUT(
        stubs: [PaymentTriggerState],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        paymentTriggerSpy: PaymentTriggerSpy
    ) {
        
        let spy = PaymentTriggerSpy(stubs: stubs)
        let sut = SUT(
            handlePaymentTriggerEvent: spy.call,
            factory: .init(
                getFormattedAmount: { _ in "" },
                makeFraud: { _ in unimplemented() },
                makeUtilityPrepaymentState: { _ in unimplemented() },
                makeUtilityPaymentState: { _,_ in unimplemented() },
                makePayByInstructionsViewModel: { _ in unimplemented() }
            ),
            closeAction: {},
            notify: { _ in }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func makeState(
    ) -> SUT.State {
        
        return .empty
    }
    
    private func makeLegacyPaymentTriggerState(
        _ legacy: PaymentTriggerState.Legacy
    ) -> PaymentTriggerState {
        
        return .legacy(legacy)
    }
    
    private func makePaymentTriggerState() -> PaymentTriggerState {
        
        return .v1
    }
    
    private func makeLatestPayment(
        id: Int = .random(in: 1...1_000),
        date: Date = .init(),
        paymentDate: String = anyMessage(),
        type: LatestPaymentData.Kind = .service
    ) -> LatestPaymentData {
        
        return .init(id: id, date: date, paymentDate: paymentDate, type: type)
    }
}
