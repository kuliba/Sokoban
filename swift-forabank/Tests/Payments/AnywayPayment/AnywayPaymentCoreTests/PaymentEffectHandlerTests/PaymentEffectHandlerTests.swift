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
        
        let (_, parameterEffectHandler, paymentInitiator, paymentMaker, processing) = makeSUT()
        
        XCTAssertEqual(parameterEffectHandler.callCount, 0)
        XCTAssertEqual(paymentInitiator.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
        XCTAssertEqual(processing.callCount, 0)
    }
    
    // MARK: - continue
    
    func test_continue_shouldCallProcessingWithDigest() {
        
        let digest = makeDigest()
        let (sut, _,_,_, processing) = makeSUT()
        
        sut.handleEffect(.continue(digest)) { _ in }
        
        XCTAssertNoDiff(processing.payloads, [digest])
    }
    
    func test_continue_shouldDeliverConnectivityErrorOnProcessingConnectivityErrorFailure() {
        
        expect(
            toDeliver: updateEvent(.connectivityError),
            for: makeContinuePaymentEffect(),
            onProcessing: .failure(.connectivityError)
        )
    }
    
    func test_continue_shouldDeliverServerErrorOnProcessingServerErrorFailure() {
        
        let message = anyMessage()
        
        expect(
            toDeliver: updateEvent(.serverError(message)),
            for: makeContinuePaymentEffect(),
            onProcessing: .failure(.serverError(message))
        )
    }
    
    func test_continue_shouldDeliverUpdateOnProcessingSuccess() {
        
        let update = makeUpdate()
        
        expect(
            toDeliver: updateEvent(update),
            for: makeContinuePaymentEffect(),
            onProcessing: .success(update)
        )
    }
    
    func test_continue_shouldNotDeliverProcessingFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let processing: Processing
        (sut, _,_,_, processing) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makeContinuePaymentEffect()) { received.append($0) }
        sut = nil
        processing.complete(with: .failure(.connectivityError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    func test_continue_shouldNotDeliverProcessingSuccessResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let processing: Processing
        (sut, _,_,_, processing) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makeContinuePaymentEffect()) { received.append($0) }
        sut = nil
        processing.complete(with: .success(makeUpdate()))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    // MARK: - initiatePayment
    
    func test_initiatePayment_shouldCallPaymentInitiatorWithDigest() {
        
        let digest = makeDigest()
        let (sut, _, paymentInitiator, _, _) = makeSUT()
        
        sut.handleEffect(makeInitiatePaymentEffect(digest)) { _ in }
        
        XCTAssertNoDiff(paymentInitiator.payloads, [digest])
    }
    
    func test_initiatePayment_shouldDeliverUpdateWithConnectivityErrorOnPaymentInitiatorConnectivityErrorFailure() {
        
        let (sut, _, paymentInitiator, _, _) = makeSUT()
        
        expect(
            sut,
            toDeliver: .updatePayment(.failure(.connectivityError)),
            for: makeInitiatePaymentEffect(),
            on: { paymentInitiator.complete(with: .failure(.connectivityError)) }
        )
    }
    
    func test_initiatePayment_shouldDeliverUpdateWithServerErrorOnPaymentInitiatorServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, _, paymentInitiator, _, _) = makeSUT()
        
        expect(
            sut,
            toDeliver: .updatePayment(.failure(.serverError(message))),
            for: makeInitiatePaymentEffect(),
            on: { paymentInitiator.complete(with: .failure(.serverError(message))) }
        )
    }
    
    func test_initiatePayment_shouldDeliverUpdateOnPaymentInitiatorSuccess() {
        
        let update = makeUpdate()
        let (sut, _, paymentInitiator, _, _) = makeSUT()
        
        expect(
            sut,
            toDeliver: makeUpdateTransactionEvent(update),
            for: makeInitiatePaymentEffect(),
            on: { paymentInitiator.complete(with: .success(update)) }
        )
    }
    
    func test_initiatePayment_shouldNotDeliverPaymentInitiatorResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentInitiator: PaymentInitiator
        (sut, _, paymentInitiator, _,_) = makeSUT()
        var receivedEvents = [SUT.Event]()
        
        sut?.handleEffect(makeInitiatePaymentEffect()) { receivedEvents.append($0) }
        sut = nil
        paymentInitiator.complete(with: .failure(.connectivityError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(receivedEvents.isEmpty)
    }
    
    // MARK: - makePayment
    
    func test_makePayment_shouldCallProcessingWithDigest() {
        
        let code = makeVerificationCode()
        let (sut, _,_, paymentMaker, _) = makeSUT()
        
        sut.handleEffect(.makePayment(code)) { _ in }
        
        XCTAssertNoDiff(paymentMaker.payloads, [code])
    }
    
    func test_makePayment_shouldDeliverTransactionFailureOnMakePaymentFailure() {
        
        expect(
            toDeliver: makeCompletePaymentFailureEvent(),
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
        (sut, _,_, paymentMaker, _) = makeSUT()
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
        (sut, _,_, paymentMaker, _) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makePaymentEffect()) { received.append($0) }
        sut = nil
        paymentMaker.complete(with: makeOperationDetailsTransactionReport())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    // MARK: - parameter
    
    func test_parameterEffect_shouldCallParameterEffectHandleWithEffect() {
        
        let effect = makeParameterEffect()
        let (sut, parameterEffectHandler, _,_, _) = makeSUT()
        
        sut.handleEffect(.parameter(effect)) { _ in }
        
        XCTAssertNoDiff(parameterEffectHandler.effects, [effect])
    }
    
    func test_parameterEffect_shouldDeliverParameterEffectHandleEvent() {
        
        let event = makeParameterEvent()
        let (sut, parameterEffectHandler, _,_, _) = makeSUT()
        
        expect(sut, toDeliver: .parameter(event), for:  makeParameterPaymentEffect(), on: {
            
            parameterEffectHandler.complete(with: event)
        })
    }
    
    func test_parameterEffect_shouldNotDeliverParameterEffectHandleEventOnInstanceDeallocation() {
        
        var sut: SUT?
        let parameterEffectHandler: ParameterEffectHandleSpy
        (sut, parameterEffectHandler, _,_,_) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makeParameterPaymentEffect()) { received.append($0) }
        sut = nil
        parameterEffectHandler.complete(with: makeParameterEvent())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentEffectHandler<Digest, DocumentStatus, OperationDetails, ParameterEffect, ParameterEvent, Update>
    
    private typealias PaymentInitiator = Processing
    private typealias PaymentMaker = Spy<VerificationCode, SUT.MakePaymentResult>
    private typealias ParameterEffectHandleSpy = EffectHandlerSpy<ParameterEvent, ParameterEffect>
    private typealias Processing = Spy<Digest, SUT.ProcessResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        parameterEffectHandler: ParameterEffectHandleSpy,
        paymentInitiator: PaymentInitiator,
        paymentMaker: PaymentMaker,
        processing: Processing
    ) {
        let parameterEffectHandler = ParameterEffectHandleSpy()
        let paymentInitiator = PaymentInitiator()
        let paymentMaker = PaymentMaker()
        let processing = Processing()
        
        let sut = SUT(
            initiatePayment: paymentInitiator.process,
            makePayment: paymentMaker.process,
            parameterEffectHandle: parameterEffectHandler.handleEffect,
            processPayment: processing.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(parameterEffectHandler, file: file, line: line)
        trackForMemoryLeaks(paymentInitiator, file: file, line: line)
        trackForMemoryLeaks(paymentMaker, file: file, line: line)
        trackForMemoryLeaks(processing, file: file, line: line)
        
        return (sut, parameterEffectHandler, paymentInitiator, paymentMaker, processing)
    }
    
    private func updateEvent(
        _ update: Update
    ) -> SUT.Event {
        
        .updatePayment(.success(update))
    }
    
    private func updateEvent(
        _ serviceFailure: ServiceFailure
    ) -> SUT.Event {
        
        .updatePayment(.failure(serviceFailure))
    }
    
    private func expect(
        toDeliver expectedEvent: SUT.Event,
        for effect: SUT.Effect,
        onProcessing processingResult: SUT.ProcessResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (sut, _,_,_, processing) = makeSUT()
        expect(sut, toDeliver: expectedEvent, for: effect, on: { processing.complete(with: processingResult) }, file: file, line: line)
    }
    
    private func expect(
        toDeliver expectedEvent: SUT.Event,
        for effect: SUT.Effect,
        onMakePayment makePaymentResult: SUT.MakePaymentResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (sut, _,_, paymentMaker, _) = makeSUT()
        expect(sut, toDeliver: expectedEvent, for: effect, on: { paymentMaker.complete(with: makePaymentResult) }, file: file, line: line)
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
) -> TransactionEvent<DocumentStatus, OperationDetails, ParameterEvent, Update> {
    
    .completePayment(transactionReport)
}
