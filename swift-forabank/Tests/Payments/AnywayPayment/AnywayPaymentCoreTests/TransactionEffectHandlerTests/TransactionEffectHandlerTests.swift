//
//  TransactionEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 28.03.2024.
//

import AnywayPaymentDomain
import AnywayPaymentCore
import XCTest

final class TransactionEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getVerificationCodeSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing) = makeSUT()
        
        XCTAssertEqual(getVerificationCodeSpy.callCount, 0)
        XCTAssertEqual(paymentEffectHandler.callCount, 0)
        XCTAssertEqual(paymentInitiator.callCount, 0)
        XCTAssertEqual(paymentMaker.callCount, 0)
        XCTAssertEqual(paymentProcessing.callCount, 0)
    }
    
    // MARK: - continue
    
    func test_continue_shouldCallProcessingWithDigest() {
        
        let digest = makePaymentDigest()
        let (sut, _,_,_,_, paymentProcessing) = makeSUT()
        
        sut.handleEffect(.continue(digest)) { _ in }
        
        XCTAssertNoDiff(paymentProcessing.payloads, [digest])
    }
    
    func test_continue_shouldDeliverConnectivityErrorOnProcessingConnectivityErrorFailure() {
        
        expect(
            toDeliver: updateEvent(.connectivityError),
            for: makeContinueTransactionEffect(),
            onProcessing: .failure(.connectivityError)
        )
    }
    
    func test_continue_shouldDeliverServerErrorOnProcessingServerErrorFailure() {
        
        let message = anyMessage()
        
        expect(
            toDeliver: updateEvent(.serverError(message)),
            for: makeContinueTransactionEffect(),
            onProcessing: .failure(.serverError(message))
        )
    }
    
    func test_continue_shouldDeliverUpdateOnProcessingSuccess() {
        
        let update = makeUpdate()
        
        expect(
            toDeliver: updateEvent(update),
            for: makeContinueTransactionEffect(),
            onProcessing: .success(update)
        )
    }
    
    func test_continue_shouldNotDeliverProcessingFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentProcessing: PaymentProcessing
        (sut, _,_,_,_, paymentProcessing) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makeContinueTransactionEffect()) { received.append($0) }
        sut = nil
        paymentProcessing.complete(with: .failure(.connectivityError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    func test_continue_shouldNotDeliverProcessingSuccessResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentProcessing: PaymentProcessing
        (sut, _,_,_,_, paymentProcessing) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makeContinueTransactionEffect()) { received.append($0) }
        sut = nil
        paymentProcessing.complete(with: .success(makeUpdate()))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    // MARK: - getVerificationCode
    
    func test_getVerificationCode_shouldCallGetVerificationCode() {
        
        let (sut, getCodeSpy, _,_,_,_) = makeSUT()
        
        sut.handleEffect(.getVerificationCode) { _ in }
        
        XCTAssertEqual(getCodeSpy.callCount, 1)
    }
    
    func test_getVerificationCode_shouldDeliverConnectivityErrorOnGetVerificationCodeConnectivityFailure() {
        
        let (sut, getCodeSpy, _,_,_,_) = makeSUT()
        
        expect(
            sut,
            toDeliver: .verificationCode(.receive(.failure(.connectivityError))),
            for: .getVerificationCode
        ) {
            getCodeSpy.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_getVerificationCode_shouldDeliverServerErrorOnGetVerificationCodeServerFailure() {
        
        let message = anyMessage()
        let (sut, getCodeSpy, _,_,_,_) = makeSUT()
        
        expect(
            sut,
            toDeliver: .verificationCode(.receive(.failure(.serverError(message)))),
            for: .getVerificationCode
        ) {
            getCodeSpy.complete(with: .failure(.serverError(message)))
        }
    }
    
    func test_getVerificationCode_shouldDeliverResendOTPCountOnGetVerificationCodeSuccess() {
        
        let resendOTPCount = Int.random(in: 1...10)
        let (sut, getCodeSpy, _,_,_,_) = makeSUT()
        
        expect(
            sut,
            toDeliver: .verificationCode(.receive(.success(resendOTPCount))),
            for: .getVerificationCode
        ) {
            getCodeSpy.complete(with: .success(resendOTPCount))
        }
    }
    
    // MARK: - initiatePayment
    
    func test_initiatePayment_shouldCallPaymentInitiatorWithDigest() {
        
        let digest = makePaymentDigest()
        let (sut, _,_, paymentInitiator, _, _) = makeSUT()
        
        sut.handleEffect(makeInitiateTransactionEffect(digest)) { _ in }
        
        XCTAssertNoDiff(paymentInitiator.payloads, [digest])
    }
    
    func test_initiatePayment_shouldDeliverUpdateWithConnectivityErrorOnPaymentInitiatorConnectivityErrorFailure() {
        
        let (sut, _,_, paymentInitiator, _, _) = makeSUT()
        
        expect(
            sut,
            toDeliver: .updatePayment(.failure(.connectivityError)),
            for: makeInitiateTransactionEffect(),
            on: { paymentInitiator.complete(with: .failure(.connectivityError)) }
        )
    }
    
    func test_initiatePayment_shouldDeliverUpdateWithServerErrorOnPaymentInitiatorServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, _,_, paymentInitiator, _, _) = makeSUT()
        
        expect(
            sut,
            toDeliver: .updatePayment(.failure(.serverError(message))),
            for: makeInitiateTransactionEffect(),
            on: { paymentInitiator.complete(with: .failure(.serverError(message))) }
        )
    }
    
    func test_initiatePayment_shouldDeliverUpdateOnPaymentInitiatorSuccess() {
        
        let update = makeUpdate()
        let (sut, _,_, paymentInitiator, _, _) = makeSUT()
        
        expect(
            sut,
            toDeliver: makeUpdateTransactionEvent(update),
            for: makeInitiateTransactionEffect(),
            on: { paymentInitiator.complete(with: .success(update)) }
        )
    }
    
    func test_initiatePayment_shouldNotDeliverPaymentInitiatorResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentInitiator: PaymentInitiator
        (sut, _,_, paymentInitiator, _,_) = makeSUT()
        var receivedEvents = [SUT.Event]()
        
        sut?.handleEffect(makeInitiateTransactionEffect()) { receivedEvents.append($0) }
        sut = nil
        paymentInitiator.complete(with: .failure(.connectivityError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(receivedEvents.isEmpty)
    }
    
    // MARK: - makePayment
    
    func test_makePayment_shouldCallProcessingWithDigest() {
        
        let code = makeVerificationCode()
        let (sut, _,_,_, paymentMaker, _) = makeSUT()
        
        sut.handleEffect(.makePayment(code)) { _ in }
        
        XCTAssertNoDiff(paymentMaker.payloads, [code])
    }
    
    func test_makePayment_shouldDeliverTransactionFailureOnMakePaymentFailure() {
        
        expect(
            toDeliver: makeCompletePaymentFailureEvent(),
            for: makeTransactionEffect(),
            onMakePayment: .failure(.terminal)
        )
    }
    
    func test_makePayment_shouldDeliverDetailIDOnOperationDetailID() {
        
        let transactionReport = makeDetailIDTransactionReport()
        
        expect(
            toDeliver: completeWithReport(transactionReport),
            for: makeTransactionEffect(),
            onMakePayment: .success(transactionReport)
        )
    }
    
    func test_makePayment_shouldDeliverOperationDetailsOnOperationDetails() {
        
        let transactionReport = makeOperationDetailsTransactionReport()
        
        expect(
            toDeliver: completeWithReport(transactionReport),
            for: makeTransactionEffect(),
            onMakePayment: .success(transactionReport)
        )
    }
    
    func test_makePayment_shouldNotDeliverPaymentFailureOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentMaker: PaymentMaker
        (sut, _,_,_, paymentMaker, _) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makeTransactionEffect()) { received.append($0) }
        sut = nil
        paymentMaker.complete(with: .failure(.terminal))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    func test_makePayment_shouldNotDeliverPaymentResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentMaker: PaymentMaker
        (sut, _,_,_, paymentMaker, _) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makeTransactionEffect()) { received.append($0) }
        sut = nil
        paymentMaker.complete(with: .success(makeOperationDetailsTransactionReport()))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    // MARK: - payment
    
    func test_paymentEffect_shouldCallPaymentEffectHandleWithEffect() {
        
        let effect = makePaymentEffect()
        let (sut, _, paymentEffectHandler, _,_, _) = makeSUT()
        
        sut.handleEffect(.payment(effect)) { _ in }
        
        XCTAssertNoDiff(paymentEffectHandler.effects, [effect])
    }
    
    func test_paymentEffect_shouldDeliverPaymentEffectHandleEvent() {
        
        let event = makePaymentEvent()
        let (sut, _, paymentEffectHandler, _,_, _) = makeSUT()
        
        expect(sut, toDeliver: .payment(event), for:  makePaymentTransactionEffect(), on: {
            
            paymentEffectHandler.complete(with: event)
        })
    }
    
    func test_paymentEffect_shouldNotDeliverPaymentEffectHandleEventOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentEffectHandler: PaymentEffectHandleSpy
        (sut, _, paymentEffectHandler, _,_,_) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makePaymentTransactionEffect()) { received.append($0) }
        sut = nil
        paymentEffectHandler.complete(with: makePaymentEvent())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = _TransactionEffectHandler
    private typealias GetVerificationCodeSpy = Spy<Void, SUT.Event.VerificationCode.GetVerificationCodeResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getVerificationCodeSpy: GetVerificationCodeSpy,
        paymentEffectHandler: PaymentEffectHandleSpy,
        paymentInitiator: PaymentInitiator,
        paymentMaker: PaymentMaker,
        paymentProcessing: PaymentProcessing
    ) {
        let getVerificationCodeSpy = GetVerificationCodeSpy()
        let paymentEffectHandler = PaymentEffectHandleSpy()
        let paymentInitiator = PaymentInitiator()
        let paymentMaker = PaymentMaker()
        let paymentProcessing = PaymentProcessing()
        
        let sut = SUT(
            microServices: .init(
                getVerificationCode: getVerificationCodeSpy.process,
                initiatePayment: paymentInitiator.process,
                makePayment: paymentMaker.process,
                paymentEffectHandle: paymentEffectHandler.handleEffect,
                processPayment: paymentProcessing.process
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getVerificationCodeSpy, file: file, line: line)
        trackForMemoryLeaks(paymentEffectHandler, file: file, line: line)
        trackForMemoryLeaks(paymentInitiator, file: file, line: line)
        trackForMemoryLeaks(paymentMaker, file: file, line: line)
        trackForMemoryLeaks(paymentProcessing, file: file, line: line)
        
        return (sut, getVerificationCodeSpy, paymentEffectHandler, paymentInitiator, paymentMaker, paymentProcessing)
    }
    
    private func updateEvent(
        _ update: PaymentUpdate
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
        onProcessing paymentProcessingResult: SUT.MicroServices.ProcessResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (sut, _,_,_,_, paymentProcessing) = makeSUT()
        expect(sut, toDeliver: expectedEvent, for: effect, on: { paymentProcessing.complete(with: paymentProcessingResult) }, file: file, line: line)
    }
    
    private func expect(
        toDeliver expectedEvent: SUT.Event,
        for effect: SUT.Effect,
        onMakePayment makePaymentResult: SUT.Event.TransactionResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let (sut, _,_,_, paymentMaker, _) = makeSUT()
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
