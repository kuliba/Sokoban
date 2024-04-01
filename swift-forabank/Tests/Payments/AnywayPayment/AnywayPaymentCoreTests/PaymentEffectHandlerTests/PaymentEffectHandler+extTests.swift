//
//  PaymentEffectHandler+extTests.swift
//
//
//  Created by Igor Malyarov on 29.03.2024.
//

import AnywayPaymentCore
import XCTest

final class PaymentEffectHandler_extTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getDetails, paymentInitiator, makeTransfer, parameterEffectHandler, processing) = makeSUT()
        
        XCTAssertEqual(getDetails.callCount, 0)
        XCTAssertEqual(paymentInitiator.callCount, 0)
        XCTAssertEqual(makeTransfer.callCount, 0)
        XCTAssertEqual(parameterEffectHandler.callCount, 0)
        XCTAssertEqual(processing.callCount, 0)
    }
    
    // MARK: - continue
    
    func test_continue_shouldCallProcessingWithDigestOnContinueEvent() {
        
        let digest = makeDigest()
        let (sut ,_,_,_,_, processing) = makeSUT()
        
        sut.handleEffect(makeContinuePaymentEffect(digest)) { _ in }
        
        XCTAssertNoDiff(processing.payloads, [digest])
    }
    
    func test_continue_shouldDeliverUpdateWithConnectivityErrorOnProcessingConnectivityErrorFailure() {
        
        let (sut ,_,_,_,_, processing) = makeSUT()
        
        expect(
            sut,
            processing,
            toDeliver: .updatePayment(.failure(.connectivityError)),
            for: makeContinuePaymentEffect(),
            onProcessing: .failure(.connectivityError)
        )
    }
    
    func test_continue_shouldDeliverUpdateWithServerErrorOnProcessingServerErrorFailure() {
        
        let message = anyMessage()
        let (sut ,_,_,_,_, processing) = makeSUT()
        
        expect(
            sut,
            processing,
            toDeliver: .updatePayment(.failure(.serverError(message))),
            for: makeContinuePaymentEffect(),
            onProcessing: .failure(.serverError(message))
        )
    }
    
    func test_continue_shouldDeliverUpdateOnProcessingSuccess() {
        
        let update = makeUpdate()
        let (sut ,_,_,_,_, processing) = makeSUT()
        
        expect(
            sut,
            processing,
            toDeliver: makeUpdateEvent(update),
            for: makeContinuePaymentEffect(),
            onProcessing: .success(update)
        )
    }
    
    func test_continue_shouldNotDeliverProcessingResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let processing: Processing
        (sut, _,_,_,_, processing) = makeSUT()
        var receivedEvents = [SUT.Event]()
        
        sut?.handleEffect(makeContinuePaymentEffect()) { receivedEvents.append($0) }
        sut = nil
        processing.complete(with: .failure(.connectivityError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(receivedEvents.isEmpty)
    }
    
    // MARK: - initiatePayment
    
    func test_initiatePayment_shouldCallPaymentInitiatorWithDigest() {
        
        let digest = makeDigest()
        let (sut, _, paymentInitiator, _,_,_) = makeSUT()
        
        sut.handleEffect(makeInitiatePaymentEffect(digest)) { _ in }
        
        XCTAssertNoDiff(paymentInitiator.payloads, [digest])
    }
        
    func test_initiatePayment_shouldDeliverUpdateWithConnectivityErrorOnPaymentInitiatorConnectivityErrorFailure() {
        
        let (sut, _, paymentInitiator, _,_,_) = makeSUT()
        
        expect(
            sut,
            paymentInitiator,
            toDeliver: .updatePayment(.failure(.connectivityError)),
            for: makeInitiatePaymentEffect(),
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
            for: makeInitiatePaymentEffect(),
            onProcessing: .failure(.serverError(message))
        )
    }
    
    func test_initiatePayment_shouldDeliverUpdateOnPaymentInitiatorSuccess() {
        
        let update = makeUpdate()
        let (sut, _, paymentInitiator, _,_,_) = makeSUT()
        
        expect(
            sut,
            paymentInitiator,
            toDeliver: makeUpdateEvent(update),
            for: makeInitiatePaymentEffect(),
            onProcessing: .success(update)
        )
    }
    
    func test_initiatePayment_shouldNotDeliverPaymentInitiatorResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let paymentInitiator: PaymentInitiator
        (sut, _, paymentInitiator, _,_,_) = makeSUT()
        var receivedEvents = [SUT.Event]()
        
        sut?.handleEffect(makeInitiatePaymentEffect()) { receivedEvents.append($0) }
        sut = nil
        paymentInitiator.complete(with: .failure(.connectivityError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(receivedEvents.isEmpty)
    }
    
    // MARK: - makePayment
    
    func test_makePayment_shouldCallMakeTransferWithVerificationCode() {
        
        let verificationCode = makeVerificationCode()
        let (sut, _,_, makeTransfer, _,_) = makeSUT()
        
        sut.handleEffect(makePaymentEffect(verificationCode)) { _ in }
        
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
        
        sut?.handleEffect(makePaymentEffect()) { receivedEvents.append($0) }
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
        
        sut?.handleEffect(makePaymentEffect()) { receivedEvents.append($0) }
        makeTransfer.complete(with: makeResponse())
        sut = nil
        getDetails.complete(with: nil)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(receivedEvents.isEmpty)
    }
    
    // MARK: - parameter
    
    func test_parameterEffect_shouldCallParameterEffectHandleWithEffect() {
        
        let effect = makeParameterEffect()
        let (sut, _,_,_, parameterEffectHandler, _) = makeSUT()
        
        sut.handleEffect(.parameter(effect)) { _ in }
        
        XCTAssertNoDiff(parameterEffectHandler.effects, [effect])
    }
    
    func test_parameterEffect_shouldDeliverParameterEffectHandleEvent() {
        
        let event = makeParameterEvent()
        let (sut, _,_,_, parameterEffectHandler, _) = makeSUT()
        
        expect(sut, toDeliver: .parameter(event), for: makeParameterPaymentEffect(), on: {
            
            parameterEffectHandler.complete(with: event)
        })
    }
    
    func test_parameterEffect_shouldNotDeliverParameterEffectHandleEventOnInstanceDeallocation() {
        
        var sut: SUT?
        let parameterEffectHandler: ParameterEffectHandleSpy
        (sut, _,_,_, parameterEffectHandler, _) = makeSUT()
        var received = [SUT.Event]()
        
        sut?.handleEffect(makeParameterPaymentEffect()) { received.append($0) }
        sut = nil
        parameterEffectHandler.complete(with: makeParameterEvent())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(received.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentEffectHandler<Digest, DocumentStatus, OperationDetails, ParameterEffect, ParameterEvent, Update>
    
    private typealias GetDetailsSpy = Spy<SUT.Performer.PaymentOperationDetailID, SUT.Performer.GetDetailsResult>
    private typealias PaymentInitiator = Processing
    private typealias MakeTransferSpy = Spy<VerificationCode, SUT.Performer.MakeTransferResult>
    private typealias ParameterEffectHandleSpy = EffectHandlerSpy<ParameterEvent, ParameterEffect>
    private typealias Processing = Spy<Digest, SUT.ProcessResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getDetails: GetDetailsSpy,
        paymentInitiator: PaymentInitiator,
        makeTransfer: MakeTransferSpy,
        parameterEffectHandler: ParameterEffectHandleSpy,
        processing: Processing
    ) {
        let getDetails = GetDetailsSpy()
        let parameterEffectHandler = ParameterEffectHandleSpy()
        let paymentInitiator = PaymentInitiator()
        let makeTransfer = MakeTransferSpy()
        let processing = Processing()
        
        let sut = SUT(
            initiate: paymentInitiator.process,
            getDetails: getDetails.process,
            makeTransfer: makeTransfer.process,
            parameterEffectHandle: parameterEffectHandler.handleEffect,
            process: processing.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getDetails, file: file, line: line)
        trackForMemoryLeaks(paymentInitiator, file: file, line: line)
        trackForMemoryLeaks(makeTransfer, file: file, line: line)
        trackForMemoryLeaks(parameterEffectHandler, file: file, line: line)
        trackForMemoryLeaks(processing, file: file, line: line)
        
        return (sut, getDetails, paymentInitiator, makeTransfer, parameterEffectHandler, processing)
    }
    
    private func expect(
        _ sut: SUT,
        _ processing: Processing,
        toDeliver expectedEvent: SUT.Event,
        for effect: SUT.Effect,
        onProcessing processingResult: SUT.ProcessResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toDeliver: expectedEvent, for: effect, on: { processing.complete(with: processingResult) }, file: file, line: line)
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
