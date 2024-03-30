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
        
        let (_, getDetails, makeTransfer, processing) = makeSUT()
        
        XCTAssertEqual(getDetails.callCount, 0)
        XCTAssertEqual(makeTransfer.callCount, 0)
        XCTAssertEqual(processing.callCount, 0)
    }
    
    // MARK: - continue
    
    func test_continue_shouldCallProcessingWithDigestOnContinueEvent() {
        
        let digest = makeDigest()
        let (sut, _,_, processing) = makeSUT()
        
        sut.handleEffect(continueEffect(digest)) { _ in }
        
        XCTAssertNoDiff(processing.payloads, [digest])
    }
    
    func test_continue_shouldDeliverUpdateWithConnectivityErrorOnProcessingConnectivityErrorFailure() {
        
        let (sut, _,_, processing) = makeSUT()
        
        expect(
            sut,
            processing,
            toDeliver: .update(.failure(.connectivityError)),
            for: continueEffect(makeDigest()),
            onProcessing: .failure(.connectivityError)
        )
    }
    
    func test_continue_shouldDeliverUpdateWithServerErrorOnProcessingServerErrorFailure() {
        
        let message = anyMessage()
        let (sut, _,_, processing) = makeSUT()
        
        expect(
            sut,
            processing,
            toDeliver: .update(.failure(.serverError(message))),
            for: continueEffect(makeDigest()),
            onProcessing: .failure(.serverError(message))
        )
    }
    
    func test_continue_shouldDeliverUpdateOnProcessingSuccess() {
        
        let update = makeUpdate()
        let (sut, _,_, processing) = makeSUT()
        
        expect(
            sut,
            processing,
            toDeliver: .update(.success(update)),
            for: continueEffect(makeDigest()),
            onProcessing: .success(update)
        )
    }
    
    func test_continue_shouldNotDeliverProcessingResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let processing: Processing
        (sut, _,_, processing) = makeSUT()
        var receivedEvents = [SUT.Event]()
        
        sut?.handleEffect(continueEffect()) { receivedEvents.append($0) }
        sut = nil
        processing.complete(with: .failure(.connectivityError))
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(receivedEvents.isEmpty)
    }
    
    // MARK: - makePayment
    
    func test_makePayment_shouldCallMakeTransferWithVerificationCode() {
        
        let verificationCode = makeVerificationCode()
        let (sut, _, makeTransfer, _) = makeSUT()
        
        sut.handleEffect(makePaymentEffect(verificationCode)) { _ in }
        
        XCTAssertNoDiff(makeTransfer.payloads, [verificationCode])
    }
    
    func test_makePayment_shouldDeliverCompletePaymentFailureOnMakeTransferFailure() {
        
        let (sut, _, makeTransfer, _) = makeSUT()
        
        expect(sut, toDeliver: completePaymentFailureEvent(), for: .makePayment(makeVerificationCode()), on: {
            
            makeTransfer.complete(with: nil)
        })
    }
    
    func test_makePayment_shouldDeliverCompletePaymentReportWithDetailIDOnGetDetailsFailure() {
        
        let id = generateRandom11DigitNumber()
        let response = makeResponse(id: id)
        let report = makeDetailIDTransactionReport(id)
        let (sut, getDetails, makeTransfer, _) = makeSUT()
        
        expect(sut, toDeliver: completePaymentReportEvent(report), for: .makePayment(makeVerificationCode()), on: {
            
            makeTransfer.complete(with: response)
            getDetails.complete(with: nil)
        })
    }
    
    func test_makePayment_shouldDeliverCompletePaymentReportWithOperationDetailsOnGetDetailsSuccess() {
        
        let operationDetails = makeOperationDetails()
        let report = makeOperationDetailsTransactionReport(operationDetails)
        let (sut, getDetails, makeTransfer, _) = makeSUT()
        
        expect(sut, toDeliver: completePaymentReportEvent(report), for: .makePayment(makeVerificationCode()), on: {
            
            makeTransfer.complete(with: makeResponse())
            getDetails.complete(with: operationDetails)
        })
    }
    
    func test_makePayment_shouldNotDeliverMakeTransferResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let makeTransfer: MakeTransferSpy
        (sut, _, makeTransfer, _) = makeSUT()
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
        (sut, getDetails, makeTransfer, _) = makeSUT()
        var receivedEvents = [SUT.Event]()
        
        sut?.handleEffect(makePaymentEffect()) { receivedEvents.append($0) }
        makeTransfer.complete(with: makeResponse())
        sut = nil
        getDetails.complete(with: nil)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssert(receivedEvents.isEmpty)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PaymentEffectHandler<Digest, DocumentStatus, OperationDetails, ParameterEffect, ParameterEvent, Update>
    
    private typealias MakeTransferSpy = Spy<VerificationCode, SUT.Performer.MakeTransferResult>
    private typealias GetDetailsSpy = Spy<SUT.Performer.PaymentOperationDetailID, SUT.Performer.GetDetailsResult>
    private typealias Processing = Spy<Digest, SUT.ProcessResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getDetails: GetDetailsSpy,
        makeTransfer: MakeTransferSpy,
        processing: Processing
    ) {
        let getDetails = GetDetailsSpy()
        let makeTransfer = MakeTransferSpy()
        let processing = Processing()
        
        let sut = SUT(
            getDetails: getDetails.process,
            makeTransfer: makeTransfer.process,
            process: processing.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getDetails, file: file, line: line)
        trackForMemoryLeaks(makeTransfer, file: file, line: line)
        trackForMemoryLeaks(processing, file: file, line: line)
        
        return (sut, getDetails, makeTransfer, processing)
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
