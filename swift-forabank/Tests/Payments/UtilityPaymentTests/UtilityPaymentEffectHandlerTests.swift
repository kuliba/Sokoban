//
//  UtilityPaymentEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 04.03.2024.
//

import UtilityPayment
import XCTest

final class UtilityPaymentEffectHandlerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, createAnywayTransferSpy, makeTransferSpy) = makeSUT()
        
        XCTAssertEqual(createAnywayTransferSpy.callCount, 0)
        XCTAssertEqual(makeTransferSpy.callCount, 0)
    }
    
    // MARK: - makeTransfer
    
    func test_makeTransfer_shouldCallMakeTransferWithVerificationCode() {
        
        let verificationCode = makeVerificationCode()
        let (sut, createAnywayTransferSpy, makeTransferSpy) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(
            .makeTransfer(verificationCode)
        ) { _ in exp.fulfill() }
        
        makeTransferSpy.complete(with: .failure(anyError()))
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(makeTransferSpy.payloads, [verificationCode])
    }
    
    func test_makeTransfer_shouldDeliverReceivedTransferResultEventWithTransferErrorOnFailure() {
        
        let (sut, createAnywayTransferSpy, makeTransferSpy) = makeSUT()
        
        expect(sut, with: .makeTransfer(makeVerificationCode()), toDeliver: .receivedTransferResult(.failure(.transferError))) {
            
            makeTransferSpy.complete(with: .failure(anyError()))
        }
    }
    
    func test_makeTransfer_shouldDeliverReceivedTransferResultSuccessOnSuccess() {
        
        let transaction = makeTransaction()
        let (sut, createAnywayTransferSpy, makeTransferSpy) = makeSUT()
        
        expect(sut, with: .makeTransfer(makeVerificationCode()), toDeliver: .receivedTransferResult(.success(transaction))) {
            
            makeTransferSpy.complete(with: .success(transaction))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityPaymentEffectHandler
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias CreateAnywayTransferSpy = Spy<SUT.CreateAnywayTransferPayload, SUT.CreateAnywayTransferResult>
    private typealias MakeTransferSpy = Spy<SUT.MakeTransferPayload, SUT.MakeTransferResult>
    
    private func makeSUT(
        debounce: DispatchTimeInterval = .milliseconds(500),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        createAnywayTransferSpy: CreateAnywayTransferSpy,
        makeTransferSpy: MakeTransferSpy
    ) {
        let createAnywayTransferSpy = CreateAnywayTransferSpy()
        let makeTransferSpy = MakeTransferSpy()
        let sut = SUT(
            createAnywayTransfer: createAnywayTransferSpy.process(_:completion:),
            makeTransfer: makeTransferSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(createAnywayTransferSpy, file: file, line: line)
        trackForMemoryLeaks(makeTransferSpy, file: file, line: line)
        
        return (sut, createAnywayTransferSpy, makeTransferSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvents: Event...,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var events = [Event]()
        
        sut.handleEffect(effect) {
            
            events.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(events, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
    
    func makeVerificationCode(
        _ value: String = UUID().uuidString
    ) -> VerificationCode {
        
        .init(value)
    }
    
    private func makeTransaction(
        _ detailID: Int = generateRandom11DigitNumber(),
        documentStatus: Transaction.DocumentStatus = .complete
    ) -> Transaction {
        
        .init(
            paymentOperationDetailID: .init(detailID),
            documentStatus: documentStatus
        )
    }
}
