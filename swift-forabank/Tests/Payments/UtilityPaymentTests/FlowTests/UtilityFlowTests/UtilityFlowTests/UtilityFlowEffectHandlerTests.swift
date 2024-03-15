//
//  UtilityFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment
import XCTest

final class UtilityFlowEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, loader, paymentStarter) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
        XCTAssertEqual(paymentStarter.callCount, 0)
    }
    
    // MARK: - initiate
    
    func test_initiate_shouldDeliverFailureOnLoadFailure() {
        
        let (sut, loader, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.failure)) {
            
            loader.complete(with: .failure(anyError()))
        }
    }
    
    func test_initiate_shouldDeliverFailureOnEmptyOperatorListLoadSuccess_emptyLastPayments() {
        
        let (sut, loader, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.failure)) {
            
            loader.complete(with: .success(([], [])))
        }
    }
    
    func test_initiate_shouldDeliverFailureOnEmptyOperatorListLoadSuccess_nonEmptyLastPayments() {
        
        let (sut, loader, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.failure)) {
            
            loader.complete(with: .success(([makeLastPayment()], [])))
        }
    }
    
    func test_initiate_shouldDeliverOperatorListLoadSuccess_emptyLastPayments() {
        
        let `operator` = makeOperator()
        let (sut, loader, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.success([], [`operator`]))) {
            
            loader.complete(with: .success(([], [`operator`])))
        }
    }
    
    func test_initiate_shouldDeliverOperatorListLoadSuccess_nonEmptyLastPayments() {
        
        let lastPayment = makeLastPayment()
        let `operator` = makeOperator()
        let (sut, loader, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.success([lastPayment], [`operator`]))) {
            
            loader.complete(with: .success(([lastPayment], [`operator`])))
        }
    }
    
    // MARK: - select
    
    func test_select_lastPayment_shouldCallPaymentStarterWithPayload() {
        
        let lastPayment = makeLastPayment()
        let (sut, _, paymentStarter) = makeSUT()
        
        sut.handleEffect(.select(.last(lastPayment))) { _ in }
        
        XCTAssertNoDiff(paymentStarter.payloads, [.last(lastPayment)])
    }
    
    func test_select_lastPayment_shouldDeliverConnectivityErrorOnConnectivityErrorFailure() {
        
        let lastPayment = makeLastPayment()
        let (sut, _, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.last(lastPayment)), toDeliver: .paymentStarted(.failure(.connectivityError))) {
            
            paymentStarter.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_select_lastPayment_shouldDeliverServerErrorOnServerErrorFailure() {
        
        let lastPayment = makeLastPayment()
        let message = anyMessage()
        let (sut, _, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.last(lastPayment)), toDeliver: .paymentStarted(.failure(.serverError(message)))) {
            
            paymentStarter.complete(with: .failure(.serverError(message)))
        }
    }
    
    func test_select_lastPayment_shouldDeliverResponseOnSuccess() {
        
        let lastPayment = makeLastPayment()
        let response = makeResponse()
        let (sut, _, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.last(lastPayment)), toDeliver: .paymentStarted(.success(response))) {
            
            paymentStarter.complete(with: .success(response))
        }
    }
    
    func test_select_operator_shouldCallPaymentStarterWithPayload() {
        
        let `operator` = makeOperator()
        let (sut, _, paymentStarter) = makeSUT()
        
        sut.handleEffect(.select(.operator(`operator`))) { _ in }
        
        XCTAssertNoDiff(paymentStarter.payloads, [.operator(`operator`)])
    }
    
    func test_select_operator_shouldDeliverConnectivityErrorOnConnectivityErrorFailure() {
        
        let `operator` = makeOperator()
        let (sut, _, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .paymentStarted(.failure(.connectivityError))) {
            
            paymentStarter.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_select_operator_shouldDeliverServerErrorOnServerErrorFailure() {
        
        let `operator` = makeOperator()
        let message = anyMessage()
        let (sut, _, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .paymentStarted(.failure(.serverError(message)))) {
            
            paymentStarter.complete(with: .failure(.serverError(message)))
        }
    }
    
    func test_select_operator_shouldDeliverResponseOnSuccess() {
        
        let `operator` = makeOperator()
        let response = makeResponse()
        let (sut, _, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .paymentStarted(.success(response))) {
            
            paymentStarter.complete(with: .success(response))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityFlowEffectHandler<LastPayment, Operator, StartPaymentResponse>
    
    private typealias Destination = UtilityDestination<LastPayment, Operator>
    
    private typealias State = Flow<Destination>
    private typealias Event = UtilityFlowEvent<LastPayment, Operator, StartPaymentResponse>
    private typealias Effect = UtilityFlowEffect<LastPayment, Operator>
    
    private typealias LoaderSpy = Spy<Void, SUT.LoadResult>
    private typealias PaymentStarterSpy = Spy<SUT.StartPaymentPayload, SUT.StartPaymentResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loader: LoaderSpy,
        paymentStarter: PaymentStarterSpy
    ) {
        let paymentStarter = PaymentStarterSpy()
        let loader = LoaderSpy()
        let sut = SUT(
            load: loader.process,
            startPayment: paymentStarter.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(paymentStarter, file: file, line: line)
        
        return (sut, loader, paymentStarter)
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
}
