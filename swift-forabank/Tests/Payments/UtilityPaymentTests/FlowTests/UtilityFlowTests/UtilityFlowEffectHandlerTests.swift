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
        
        let (_, optionsEffectHandler, prepaymentLoader, servicesLoader, paymentStarter) = makeSUT()
        
        XCTAssertEqual(optionsEffectHandler.callCount, 0)
        XCTAssertEqual(prepaymentLoader.callCount, 0)
        XCTAssertEqual(paymentStarter.callCount, 0)
        XCTAssertEqual(servicesLoader.callCount, 0)
    }
    
    // MARK: - initiatePrepayment
    
    func test_initiatePrepayment_shouldDeliverFailureOnPrepaymentLoaderFailure() {
        
        let (sut, _, prepaymentLoader, _, _) = makeSUT()
        
        expect(sut, with: .initiatePrepayment, toDeliver: .prepaymentLoaded(.failure)) {
            
            prepaymentLoader.complete(with: .failure(anyError()))
        }
    }
    
    func test_initiatePrepayment_shouldDeliverFailureOnEmptyOperatorListPrepaymentLoaderSuccess_emptyLastPayments() {
        
        let (sut, _, prepaymentLoader, _, _) = makeSUT()
        
        expect(sut, with: .initiatePrepayment, toDeliver: .prepaymentLoaded(.failure)) {
            
            prepaymentLoader.complete(with: .success(([], [])))
        }
    }
    
    func test_initiatePrepayment_shouldDeliverFailureOnEmptyOperatorListPrepaymentLoaderSuccess_nonEmptyLastPayments() {
        
        let (sut, _, prepaymentLoader, _, _) = makeSUT()
        
        expect(sut, with: .initiatePrepayment, toDeliver: .prepaymentLoaded(.failure)) {
            
            prepaymentLoader.complete(with: .success(([makeLastPayment()], [])))
        }
    }
    
    func test_initiatePrepayment_shouldDeliverOperatorListPrepaymentLoaderSuccess_emptyLastPayments() {
        
        let `operator` = makeOperator()
        let (sut, _, prepaymentLoader, _, _) = makeSUT()
        
        expect(sut, with: .initiatePrepayment, toDeliver: .prepaymentLoaded(.success([], [`operator`]))) {
            
            prepaymentLoader.complete(with: .success(([], [`operator`])))
        }
    }
    
    func test_initiatePrepayment_shouldDeliverOperatorListPrepaymentLoaderSuccess_nonEmptyLastPayments() {
        
        let (lastPayment, `operator`) = (makeLastPayment(), makeOperator())
        let (sut, _, prepaymentLoader, _, _) = makeSUT()
        
        expect(sut, with: .initiatePrepayment, toDeliver: .prepaymentLoaded(.success([lastPayment], [`operator`]))) {
            
            prepaymentLoader.complete(with: .success(([lastPayment], [`operator`])))
        }
    }
    
    // MARK: - prepaymentOptionsEffect
    
    func test_prepaymentOptionsEffect_shouldCallOptionsEffectHandlerWithEffect_paginate() {
        
        let (sut, optionsEffectHandler, _,_,_) = makeSUT()
        
        sut.handleEffect(.prepaymentOptions(.paginate("abc123", 654))) { _ in }
        
        XCTAssertNoDiff(optionsEffectHandler.payloads, [.paginate("abc123", 654)])
    }
    
    func test_prepaymentOptionsEffect_shouldCallOptionsEffectHandlerWithEffect_search() {
        
        let (sut, optionsEffectHandler, _,_,_) = makeSUT()
        
        sut.handleEffect(.prepaymentOptions(.search("123abc"))) { _ in }
        
        XCTAssertNoDiff(optionsEffectHandler.payloads, [.search("123abc")])
    }
    
    func test_prepaymentOptionsEffect_shouldDeliverOptionsEvent_paginated() {
        
        let (sut, optionsEffectHandler, _,_,_) = makeSUT()
        
        expect(sut, with: .prepaymentOptions(.paginate("abc123", 654)), toDeliver: .prepaymentOptions(.search(.entered("123abc")))) {
            
            optionsEffectHandler.complete(with: .search(.entered("123abc")))
        }
    }
    
    func test_prepaymentOptionsEffect_shouldDeliverOptionsEvent_search() {
        
        let (sut, optionsEffectHandler, _,_,_) = makeSUT()
        
        expect(sut, with: .prepaymentOptions(.search("abc123")), toDeliver: .prepaymentOptions(.paginated(.failure(.connectivityError)))) {
            
            optionsEffectHandler.complete(with: .paginated(.failure(.connectivityError)))
        }
    }
    
    // MARK: - select
    
    func test_select_lastPayment_shouldCallPaymentStarterWithLastPayment() {
        
        let lastPayment = makeLastPayment()
        let (sut, _,_,_, paymentStarter) = makeSUT()
        
        sut.handleEffect(.select(.last(lastPayment))) { _ in }
        
        XCTAssertNoDiff(paymentStarter.payloads, [.withLastPayment(lastPayment)])
    }
    
    func test_select_lastPayment_shouldDeliverConnectivityErrorOnConnectivityErrorFailure() {
        
        let lastPayment = makeLastPayment()
        let (sut, _,_,_, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.last(lastPayment)), toDeliver: .paymentStarted(.failure(.connectivityError))) {
            
            paymentStarter.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_select_lastPayment_shouldDeliverServerErrorOnServerErrorFailure() {
        
        let lastPayment = makeLastPayment()
        let message = anyMessage()
        let (sut, _,_,_, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.last(lastPayment)), toDeliver: .paymentStarted(.failure(.serverError(message)))) {
            
            paymentStarter.complete(with: .failure(.serverError(message)))
        }
    }
    
    func test_select_lastPayment_shouldDeliverResponseOnSuccess() {
        
        let lastPayment = makeLastPayment()
        let response = makeResponse()
        let (sut, _,_,_, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.last(lastPayment)), toDeliver: .paymentStarted(.success(response))) {
            
            paymentStarter.complete(with: .success(response))
        }
    }
    
    func test_select_operator_shouldCallPaymentStarterWithPayload() {
        
        let `operator` = makeOperator()
        let (sut, _,_, servicesLoader, _) = makeSUT()
        
        sut.handleEffect(.select(.operator(`operator`))) { _ in }
        
        XCTAssertNoDiff(servicesLoader.payloads, [`operator`])
    }
    
    func test_select_operator_shouldDeliverSelectFailureOnLoadServiceFailure() {
        
        let `operator` = makeOperator()
        let (sut, _,_, servicesLoader, _) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .selectFailure(`operator`)) {
            
            servicesLoader.complete(with: .failure(anyError())) // d3, d4, d5
        }
    }
    
    func test_select_operator_shouldDeliverStartPaymentConnectivityErrorOnSingleServiceAndStartPaymentConnectivityErrorFailure() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let (sut, _,_, servicesLoader, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .paymentStarted(.failure(.connectivityError))) {
            
            servicesLoader.complete(with: .success([service]))
            paymentStarter.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_select_operator_shouldDeliverSelectFailureOnEmptyServices() {
        
        let `operator` = makeOperator()
        let (sut, _,_, servicesLoader, _) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .selectFailure(`operator`)) {
            
            servicesLoader.complete(with: .success([]))
        }
    }
    
    func test_select_operator_shouldDeliverStartPaymentServerErrorOnSingleServiceAndStartPaymentServerErrorFailure() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let message = anyMessage()
        let (sut, _,_, servicesLoader, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .paymentStarted(.failure(.serverError(message)))) {
            
            servicesLoader.complete(with: .success([service]))
            paymentStarter.complete(with: .failure(.serverError(message)))
        }
    }
    
    func test_select_operator_shouldDeliverStartPaymentSuccessOnSingleServiceAndStartPaymentSuccess() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let response = makeResponse()
        let (sut, _,_, servicesLoader, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .paymentStarted(.success(response))) {
            
            servicesLoader.complete(with: .success([service]))
            paymentStarter.complete(with: .success(response))
        }
    }
    
    func test_select_operator_shouldDeliverServicesOnServicesList() {
        
        let `operator` = makeOperator()
        let services = [makeService(), makeService()]
        let (sut, _,_, servicesLoader, _) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .servicesLoaded(services)) {
            
            servicesLoader.complete(with: .success(services))
        }
    }
    
    func test_select_service_shouldCallPaymentStarterWithServiceAndOperator() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let (sut, _,_,_, paymentStarter) = makeSUT()
        
        sut.handleEffect(.select(.service(service, for: `operator`))) { _ in }
        
        XCTAssertNoDiff(paymentStarter.payloads, [.withService(service, for: `operator`)])
    }
    
    func test_select_service_shouldDeliverConnectivityErrorOnConnectivityErrorFailure() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let (sut, _,_,_, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.service(service, for: `operator`)), toDeliver: .paymentStarted(.failure(.connectivityError))) {
            
            paymentStarter.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_select_service_shouldDeliverServerErrorOnServerErrorFailure() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let message = anyMessage()
        let (sut, _,_,_, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.service(service, for: `operator`)), toDeliver: .paymentStarted(.failure(.serverError(message)))) {
            
            paymentStarter.complete(with: .failure(.serverError(message)))
        }
    }
    
    func test_select_service_shouldDeliverResponseOnSuccess() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let response = makeResponse()
        let (sut, _,_,_, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.service(service, for: `operator`)), toDeliver: .paymentStarted(.success(response))) {
            
            paymentStarter.complete(with: .success(response))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityEffectHandler
    
    private typealias State = UtilityFlow
    private typealias Event = UtilityEvent
    private typealias Effect = UtilityEffect
    
    private typealias PrepaymentLoaderSpy = Spy<Void, SUT.LoadPrepaymentOptionsResult>
    private typealias PrepaymentOptionsEffectHandleSpy = Spy<SUT.OptionsEffect, SUT.OptionsEvent>
    private typealias PaymentStarterSpy = Spy<SUT.StartPaymentPayload, SUT.StartPaymentResult>
    private typealias ServicesLoaderSpy = Spy<SUT.LoadServicesPayload, SUT.LoadServicesResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        optionsEffectHandler: PrepaymentOptionsEffectHandleSpy,
        prepaymentLoader: PrepaymentLoaderSpy,
        servicesLoader: ServicesLoaderSpy,
        paymentStarter: PaymentStarterSpy
    ) {
        let optionsEffectHandler = PrepaymentOptionsEffectHandleSpy()
        let prepaymentLoader = PrepaymentLoaderSpy()
        let servicesLoader = ServicesLoaderSpy()
        let paymentStarter = PaymentStarterSpy()
        
        let sut = SUT(
            loadPrepaymentOptions: prepaymentLoader.process,
            loadServices: servicesLoader.process,
            optionsEffectHandle: optionsEffectHandler.process,
            startPayment: paymentStarter.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(optionsEffectHandler, file: file, line: line)
        trackForMemoryLeaks(prepaymentLoader, file: file, line: line)
        trackForMemoryLeaks(servicesLoader, file: file, line: line)
        trackForMemoryLeaks(paymentStarter, file: file, line: line)
        
        return (sut, optionsEffectHandler, prepaymentLoader, servicesLoader, paymentStarter)
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
