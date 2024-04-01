//
//  TransactionEffectHandler+extTests.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

import AnywayPaymentCore
import XCTest

final class PaymentEffectHandler_extTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getDetails, paymentInitiator, makeTransfer, paymentEffectHandler, paymentProcessing) = makeSUT()
        
        XCTAssertEqual(getDetails.callCount, 0)
        XCTAssertEqual(paymentInitiator.callCount, 0)
        XCTAssertEqual(makeTransfer.callCount, 0)
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
        XCTAssertEqual(paymentProcessing.callCount, 0)
    }
    
    // MARK: - continue
    
    func test_continue_shouldCallProcessingWithDigestOnContinueEvent() {
        
        let digest = makePaymentDigest()
        let (sut ,_,_,_,_, paymentProcessing) = makeSUT()
        
        sut.handleEffect(makeContinueTransactionEffect(digest)) { _ in }
        
        XCTAssertNoDiff(paymentProcessing.payloads, [digest])
    }
    
    func test_continue_shouldDeliverUpdateWithConnectivityErrorOnProcessingConnectivityErrorFailure() {
        
        let (sut ,_,_,_,_, paymentProcessing) = makeSUT()
        
        expect(
            sut,
            paymentProcessing,
            toDeliver: .updatePayment(.failure(.connectivityError)),
            for: makeContinueTransactionEffect(),
            onProcessing: .failure(.connectivityError)
        )
    }
    
    func test_continue_shouldDeliverUpdateWithServerErrorOnProcessingServerErrorFailure() {
        
        let message = anyMessage()
        let (sut ,_,_,_,_, paymentProcessing) = makeSUT()
        
        expect(
            sut,
            paymentProcessing,
            toDeliver: .updatePayment(.failure(.serverError(message))),
            for: makeContinueTransactionEffect(),
            onProcessing: .failure(.serverError(message))
        )
    }
    
    func test_continue_shouldDeliverUpdateOnProcessingSuccess() {
        
        let update = makeUpdate()
        let (sut ,_,_,_,_, paymentProcessing) = makeSUT()
        
        expect(
            sut,
            paymentProcessing,
            toDeliver: makeUpdateTransactionEvent(update),
            for: makeContinueTransactionEffect(),
            onProcessing: .success(update)
        )
    }
    
    func test_continue_shouldNotDeliverProcessingResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentProcessing: PaymentProcessing
        (sut, _,_,_,_, paymentProcessing) = makeSUT()
        var receivedEvents = [SUT.Event]()
        
        sut?.handleEffect(makeContinueTransactionEffect()) { receivedEvents.append($0) }
        sut = nil
        paymentProcessing.complete(with: .failure(.connectivityError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(receivedEvents.isEmpty)
    }
    
    // MARK: - initiatePayment
    
    func test_initiatePayment_shouldCallPaymentInitiatorWithDigest() {
        
        let digest = makePaymentDigest()
        let (sut, _, paymentInitiator, _,_,_) = makeSUT()
        
        sut.handleEffect(makeInitiateTransactionEffect(digest)) { _ in }
        
        XCTAssertNoDiff(paymentInitiator.payloads, [digest])
    }
        
    func test_initiatePayment_shouldDeliverUpdateWithConnectivityErrorOnPaymentInitiatorConnectivityErrorFailure() {
        
        let (sut, _, paymentInitiator, _,_,_) = makeSUT()
        
        expect(
            sut,
            paymentInitiator,
            toDeliver: .updatePayment(.failure(.connectivityError)),
            for: makeInitiateTransactionEffect(),
            onProcessing: .failure(.connectivityError)
        )
    }
    
    func test_initiatePayment_shouldDeliverUpdateWithServerErrorOnPaymentInitiatorServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, _, paymentInitiator, _,_,_) = makeSUT()
        
        expect(
            sut,
            paymentInitiator,
            toDeliver: .updatePayment(.failure(.serverError(message))),
            for: makeInitiateTransactionEffect(),
            onProcessing: .failure(.serverError(message))
        )
    }
    
    func test_initiatePayment_shouldDeliverUpdateOnPaymentInitiatorSuccess() {
        
        let update = makeUpdate()
        let (sut, _, paymentInitiator, _,_,_) = makeSUT()
        
        expect(
            sut,
            paymentInitiator,
            toDeliver: makeUpdateTransactionEvent(update),
            for: makeInitiateTransactionEffect(),
            onProcessing: .success(update)
        )
    }
    
    func test_initiatePayment_shouldNotDeliverPaymentInitiatorResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentInitiator: PaymentInitiator
        (sut, _, paymentInitiator, _,_,_) = makeSUT()
        var receivedEvents = [SUT.Event]()
        
        sut?.handleEffect(makeInitiateTransactionEffect()) { receivedEvents.append($0) }
        sut = nil
        paymentInitiator.complete(with: .failure(.connectivityError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(receivedEvents.isEmpty)
    }
    
    // MARK: - makePayment
    
    func test_makePayment_shouldCallMakeTransferWithVerificationCode() {
        
        let verificationCode = makeVerificationCode()
        let (sut, _,_, makeTransfer, _,_) = makeSUT()
        
        sut.handleEffect(makeTransactionEffect(verificationCode)) { _ in }
        
        XCTAssertNoDiff(makeTransfer.payloads, [verificationCode])
    }
    
    func test_makePayment_shouldDeliverCompletePaymentFailureOnMakeTransferFailure() {
        
        let (sut, _,_, makeTransfer, _,_) = makeSUT()
        
        expect(sut, toDeliver: makeCompletePaymentFailureEvent(), for: .makePayment(makeVerificationCode()), on: {
            
            makeTransfer.complete(with: nil)
        })
    }
    
    func test_makePayment_shouldDeliverCompletePaymentReportWithDetailIDOnGetDetailsFailure() {
        
        let id = generateRandom11DigitNumber()
        let response = makeResponse(id: id)
        let report = makeDetailIDTransactionReport(id)
        let (sut, getDetails, _, makeTransfer, _,_) = makeSUT()
        
        expect(sut, toDeliver: makeCompletePaymentReportEvent(report), for: .makePayment(makeVerificationCode()), on: {
            
            makeTransfer.complete(with: response)
            getDetails.complete(with: nil)
        })
    }
    
    func test_makePayment_shouldDeliverCompletePaymentReportWithOperationDetailsOnGetDetailsSuccess() {
        
        let operationDetails = makeOperationDetails()
        let report = makeOperationDetailsTransactionReport(operationDetails)
        let (sut, getDetails, _, makeTransfer, _,_) = makeSUT()
        
        expect(sut, toDeliver: makeCompletePaymentReportEvent(report), for: .makePayment(makeVerificationCode()), on: {
            
            makeTransfer.complete(with: makeResponse())
            getDetails.complete(with: operationDetails)
        })
    }
    
    func test_makePayment_shouldNotDeliverMakeTransferResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let makeTransfer: MakeTransferSpy
        (sut, _,_, makeTransfer, _,_) = makeSUT()
        var receivedEvents = [SUT.Event]()
        
        sut?.handleEffect(makeTransactionEffect()) { receivedEvents.append($0) }
        sut = nil
        makeTransfer.complete(with: nil)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(receivedEvents.isEmpty)
    }
    
    func test_makePayment_shouldNotDeliverGetDetailsResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let getDetails: GetDetailsSpy
        let makeTransfer: MakeTransferSpy
        (sut, getDetails, _, makeTransfer, _,_) = makeSUT()
        var receivedEvents = [SUT.Event]()
        
        sut?.handleEffect(makeTransactionEffect()) { receivedEvents.append($0) }
        makeTransfer.complete(with: makeResponse())
        sut = nil
        getDetails.complete(with: nil)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(receivedEvents.isEmpty)
    }
    
    // MARK: - payment
    
    func test_paymentEffect_shouldCallPaymentEffectHandleWithEffect() {
        
        let effect = makePaymentEffect()
        let (sut, _,_,_, paymentEffectHandler, _) = makeSUT()
        
        sut.handleEffect(.payment(effect)) { _ in }
        
        XCTAssertNoDiff(paymentEffectHandler.effects, [effect])
    }
    
    func test_paymentEffect_shouldDeliverPaymentEffectHandleEvent() {
        
        let event = makePaymentEvent()
        let (sut, _,_,_, paymentEffectHandler, _) = makeSUT()
        
        expect(sut, toDeliver: .payment(event), for: makePaymentTransactionEffect(), on: {
            
            paymentEffectHandler.complete(with: event)
        })
    }
    
    func test_paymentEffect_shouldNotDeliverPaymentEffectHandleEventOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentEffectHandler: PaymentEffectHandleSpy
        (sut, _,_,_, paymentEffectHandler, _) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makePaymentTransactionEffect()) { received.append($0) }
        sut = nil
        paymentEffectHandler.complete(with: makePaymentEvent())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = TransactionEffectHandler<DocumentStatus, OperationDetails, PaymentDigest, PaymentEffect, PaymentEvent, PaymentUpdate>
    
    private typealias GetDetailsSpy = Spy<SUT.Performer.PaymentOperationDetailID, SUT.Performer.GetDetailsResult>
    private typealias PaymentEffectHandleSpy = EffectHandlerSpy<PaymentEvent, PaymentEffect>
    private typealias PaymentInitiator = PaymentProcessing
    private typealias MakeTransferSpy = Spy<VerificationCode, SUT.Performer.MakeTransferResult>
    private typealias PaymentProcessing = Spy<PaymentDigest, SUT.ProcessResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getDetails: GetDetailsSpy,
        paymentInitiator: PaymentInitiator,
        makeTransfer: MakeTransferSpy,
        paymentEffectHandler: PaymentEffectHandleSpy,
        paymentProcessing: PaymentProcessing
    ) {
        let getDetails = GetDetailsSpy()
        let paymentEffectHandler = PaymentEffectHandleSpy()
        let paymentInitiator = PaymentInitiator()
        let makeTransfer = MakeTransferSpy()
        let paymentProcessing = PaymentProcessing()
        
        let sut = SUT(
            initiatePayment: paymentInitiator.process,
            getDetails: getDetails.process,
            makeTransfer: makeTransfer.process,
            paymentEffectHandle: paymentEffectHandler.handleEffect,
            processPayment: paymentProcessing.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getDetails, file: file, line: line)
        trackForMemoryLeaks(paymentInitiator, file: file, line: line)
        trackForMemoryLeaks(makeTransfer, file: file, line: line)
        trackForMemoryLeaks(paymentEffectHandler, file: file, line: line)
        trackForMemoryLeaks(paymentProcessing, file: file, line: line)
        
        return (sut, getDetails, paymentInitiator, makeTransfer, paymentEffectHandler, paymentProcessing)
    }
    
    private func expect(
        _ sut: SUT,
        _ paymentProcessing: PaymentProcessing,
        toDeliver expectedEvent: SUT.Event,
        for effect: SUT.Effect,
        onProcessing paymentProcessingResult: SUT.ProcessResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toDeliver: expectedEvent, for: effect, on: { paymentProcessing.complete(with: paymentProcessingResult) }, file: file, line: line)
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
