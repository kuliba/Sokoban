//
//  PaymentEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

import AnywayPaymentCore
import XCTest

final class PaymentEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, processing, paymentMaker) = makeSUT()
        
        XCTAssertEqual(processing.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
    }
    
    // MARK: - continue
    
    func test_continue_shouldCallProcessingWithDigest() {
        
        let digest = makeDigest()
        let (sut, processing, _) = makeSUT()
        
        sut.handleEffect(.continue(digest)) { _ in }
        
        XCTAssertNoDiff(processing.payloads, [digest])
    }
    
    func test_continue_shouldDeliverConnectivityErrorOnProcessingConnectivityErrorFailure() {
        
        expect(
            toDeliver: updateEvent(.connectivityError),
            for: continueEffect(),
            onProcessing: .failure(.connectivityError)
        )
    }
    
    func test_continue_shouldDeliverServerErrorOnProcessingServerErrorFailure() {
        
        let message = anyMessage()
        expect(
            toDeliver: updateEvent(.serverError(message)),
            for: continueEffect(),
            onProcessing: .failure(.serverError(message))
        )
    }
    
    func test_continue_shouldDeliverUpdateOnProcessingSuccess() {
        
        let update = makeUpdate()
        expect(
            toDeliver: updateEvent(update),
            for: continueEffect(),
            onProcessing: .success(update)
        )
    }
    
    func test_continue_shouldNotDeliverProcessingFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let processing: Processing
        (sut, processing, _) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(continueEffect()) { received.append($0) }
        sut = nil
        processing.complete(with: .failure(.connectivityError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    func test_continue_shouldNotDeliverProcessingSuccessResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let processing: Processing
        (sut, processing, _) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(continueEffect()) { received.append($0) }
        sut = nil
        processing.complete(with: .success(makeUpdate()))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    // MARK: - makePayment
    
    func test_makePayment_shouldCallProcessingWithDigest() {
        
        let code = makeVerificationCode()
        let (sut, _, paymentMaker) = makeSUT()
        
        sut.handleEffect(.makePayment(code)) { _ in }
        
        XCTAssertNoDiff(paymentMaker.payloads, [code])
    }
    
    func test_makePayment_shouldDeliverTransactionFailureOnMakePaymentFailure() {
        
        expect(
            toDeliver: completePaymentFailureEvent(),
            for: makePaymentEffect(),
            onMakePayment: nil
        )
    }
    
    func test_makePayment_shouldDeliverDetailIDOnOperationDetailID() {
        
        let transactionReport = makeDetailIDTransactionReport()
        expect(
            toDeliver: transactionReportEvent(transactionReport),
            for: makePaymentEffect(),
            onMakePayment: transactionReport
        )
    }
    
    func test_makePayment_shouldDeliverOperationDetailsOnOperationDetails() {
        
        let transactionReport = makeOperationDetailsTransactionReport()
        expect(
            toDeliver: transactionReportEvent(transactionReport),
            for: makePaymentEffect(),
            onMakePayment: transactionReport
        )
    }
    
    func test_makePayment_shouldNotDeliverPaymentFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentMaker: PaymentMaker
        (sut, _, paymentMaker) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makePaymentEffect()) { received.append($0) }
        sut = nil
        paymentMaker.complete(with: nil)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    func test_makePayment_shouldNotDeliverPaymentResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentMaker: PaymentMaker
        (sut, _, paymentMaker) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makePaymentEffect()) { received.append($0) }
        sut = nil
        paymentMaker.complete(with: makeOperationDetailsTransactionReport())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }

    // MARK: - Helpers
    
    private typealias SUT = PaymentEffectHandler<Digest, DocumentStatus, OperationDetails, ParameterEffect, ParameterEvent, Update>
    
    private typealias Processing = Spy<Digest, SUT.ProcessResult>
    private typealias PaymentMaker = Spy<VerificationCode, SUT.MakePaymentResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        processing: Processing,
        paymentMaker: PaymentMaker
    ) {
        let processing = Processing()
        let paymentMaker = PaymentMaker()
        let sut = SUT(
            makePayment: paymentMaker.process,
            process: processing.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(processing, file: file, line: line)
        trackForMemoryLeaks(paymentMaker, file: file, line: line)
        
        return (sut, processing, paymentMaker)
    }
    
    private func updateEvent(
        _ update: Update
    ) -> SUT.Event {
        
        .update(.success(update))
    }
    
    private func updateEvent(
        _ serviceFailure: ServiceFailure
    ) -> SUT.Event {
        
        .update(.failure(serviceFailure))
    }
    
    private func expect(
        toDeliver expectedEvent: SUT.Event,
        for effect: SUT.Effect,
        onProcessing processingResult: SUT.ProcessResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (sut, processing, _) = makeSUT()
        expect(sut, toDeliver: expectedEvent, for: effect, on: { processing.complete(with: processingResult) }, file: file, line: line)
    }
    
    private func expect(
        toDeliver expectedEvent: SUT.Event,
        for effect: SUT.Effect,
        onMakePayment makePaymentResult: SUT.MakePaymentResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (sut, _, makePayment) = makeSUT()
        expect(sut, toDeliver: expectedEvent, for: effect, on: { makePayment.complete(with: makePaymentResult) }, file: file, line: line)
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedEvent: SUT.Event,
        for effect: SUT.Effect,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(effect) {
            
            XCTAssertNoDiff(expectedEvent, $0, "Expected \(expectedEvent), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}

private func transactionReportEvent(
    _ transactionReport: TransactionReport<DocumentStatus, OperationDetails>
) -> PaymentEvent<DocumentStatus, OperationDetails, ParameterEvent, Update> {
    
    .completePayment(transactionReport)
}
