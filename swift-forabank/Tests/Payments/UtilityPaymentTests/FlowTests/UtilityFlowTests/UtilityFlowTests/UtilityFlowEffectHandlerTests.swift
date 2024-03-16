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
        
        let (_, loader, servicesLoader, paymentStarter) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
        XCTAssertEqual(paymentStarter.callCount, 0)
        XCTAssertEqual(servicesLoader.callCount, 0)
    }
    
    // MARK: - initiate
    
    func test_initiate_shouldDeliverFailureOnLoadFailure() {
        
        let (sut, loader, _, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.failure)) {
            
            loader.complete(with: .failure(anyError()))
        }
    }
    
    func test_initiate_shouldDeliverFailureOnEmptyOperatorListLoadSuccess_emptyLastPayments() {
        
        let (sut, loader, _, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.failure)) {
            
            loader.complete(with: .success(([], [])))
        }
    }
    
    func test_initiate_shouldDeliverFailureOnEmptyOperatorListLoadSuccess_nonEmptyLastPayments() {
        
        let (sut, loader, _, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.failure)) {
            
            loader.complete(with: .success(([makeLastPayment()], [])))
        }
    }
    
    func test_initiate_shouldDeliverOperatorListLoadSuccess_emptyLastPayments() {
        
        let `operator` = makeOperator()
        let (sut, loader, _, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.success([], [`operator`]))) {
            
            loader.complete(with: .success(([], [`operator`])))
        }
    }
    
    func test_initiate_shouldDeliverOperatorListLoadSuccess_nonEmptyLastPayments() {
        
        let (lastPayment, `operator`) = (makeLastPayment(), makeOperator())
        let (sut, loader, _, _) = makeSUT()
        
        expect(sut, with: .initiate, toDeliver: .loaded(.success([lastPayment], [`operator`]))) {
            
            loader.complete(with: .success(([lastPayment], [`operator`])))
        }
    }
    
    // MARK: - select
    
    func test_select_lastPayment_shouldCallPaymentStarterWithLastPayment() {
        
        let lastPayment = makeLastPayment()
        let (sut, _,_, paymentStarter) = makeSUT()
        
        sut.handleEffect(.select(.last(lastPayment))) { _ in }
        
        XCTAssertNoDiff(paymentStarter.payloads, [.last(lastPayment)])
    }
    
    func test_select_lastPayment_shouldDeliverConnectivityErrorOnConnectivityErrorFailure() {
        
        let lastPayment = makeLastPayment()
        let (sut, _,_, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.last(lastPayment)), toDeliver: .paymentStarted(.failure(.connectivityError))) {
            
            paymentStarter.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_select_lastPayment_shouldDeliverServerErrorOnServerErrorFailure() {
        
        let lastPayment = makeLastPayment()
        let message = anyMessage()
        let (sut, _,_, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.last(lastPayment)), toDeliver: .paymentStarted(.failure(.serverError(message)))) {
            
            paymentStarter.complete(with: .failure(.serverError(message)))
        }
    }
    
    func test_select_lastPayment_shouldDeliverResponseOnSuccess() {
        
        let lastPayment = makeLastPayment()
        let response = makeResponse()
        let (sut, _,_, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.last(lastPayment)), toDeliver: .paymentStarted(.success(response))) {
            
            paymentStarter.complete(with: .success(response))
        }
    }
    
    func test_select_operator_shouldCallPaymentStarterWithPayload() {
        
        let `operator` = makeOperator()
        let (sut, _, servicesLoader, _) = makeSUT()
        
        sut.handleEffect(.select(.operator(`operator`))) { _ in }
        
        XCTAssertNoDiff(servicesLoader.payloads, [`operator`])
    }
    
    func test_select_operator_shouldDeliverSelectFailureOnLoadServiceFailure() {
        
        let `operator` = makeOperator()
        let (sut, _, servicesLoader, _) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .selectFailure(`operator`)) {
            
            servicesLoader.complete(with: .failure(anyError())) // d3, d4, d5
        }
    }
    
    func test_select_operator_shouldDeliverStartPaymentConnectivityErrorOnSingleServiceAndStartPaymentConnectivityErrorFailure() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let (sut, _, servicesLoader, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .paymentStarted(.failure(.connectivityError))) {
            
            servicesLoader.complete(with: .success([service]))
            paymentStarter.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_select_operator_shouldDeliverSelectFailureOnEmptyServices() {
        
        let `operator` = makeOperator()
        let (sut, _, servicesLoader, _) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .selectFailure(`operator`)) {
            
            servicesLoader.complete(with: .success([]))
        }
    }
    
    func test_select_operator_shouldDeliverStartPaymentServerErrorOnSingleServiceAndStartPaymentServerErrorFailure() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let message = anyMessage()
        let (sut, _, servicesLoader, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .paymentStarted(.failure(.serverError(message)))) {
            
            servicesLoader.complete(with: .success([service]))
            paymentStarter.complete(with: .failure(.serverError(message)))
        }
    }
    
    func test_select_operator_shouldDeliverStartPaymentSuccessOnSingleServiceAndStartPaymentSuccess() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let response = makeResponse()
        let (sut, _, servicesLoader, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .paymentStarted(.success(response))) {
            
            servicesLoader.complete(with: .success([service]))
            paymentStarter.complete(with: .success(response))
        }
    }
    
    func test_select_operator_shouldDeliverServicesOnServicesList() {
        
        let `operator` = makeOperator()
        let services = [makeService(), makeService()]
        let (sut, _, servicesLoader, _) = makeSUT()
        
        expect(sut, with: .select(.operator(`operator`)), toDeliver: .loadedServices(services)) {
            
            servicesLoader.complete(with: .success(services))
        }
    }
    
    func test_select_service_shouldCallPaymentStarterWithServiceAndOperator() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let (sut, _,_, paymentStarter) = makeSUT()
        
        sut.handleEffect(.select(.service(service, for: `operator`))) { _ in }
        
        XCTAssertNoDiff(paymentStarter.payloads, [.service(service, for: `operator`)])
    }
    
    func test_select_service_shouldDeliverConnectivityErrorOnConnectivityErrorFailure() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let (sut, _,_, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.service(service, for: `operator`)), toDeliver: .paymentStarted(.failure(.connectivityError))) {
            
            paymentStarter.complete(with: .failure(.connectivityError))
        }
    }
    
    func test_select_service_shouldDeliverServerErrorOnServerErrorFailure() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let message = anyMessage()
        let (sut, _,_, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.service(service, for: `operator`)), toDeliver: .paymentStarted(.failure(.serverError(message)))) {
            
            paymentStarter.complete(with: .failure(.serverError(message)))
        }
    }
    
    func test_select_service_shouldDeliverResponseOnSuccess() {
        
        let (`operator`, service) = (makeOperator(), makeService())
        let response = makeResponse()
        let (sut, _,_, paymentStarter) = makeSUT()
        
        expect(sut, with: .select(.service(service, for: `operator`)), toDeliver: .paymentStarted(.success(response))) {
            
            paymentStarter.complete(with: .success(response))
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UtilityFlowEffectHandler<LastPayment, Operator, UtilityService, StartPaymentResponse>
    
    private typealias Destination = UtilityDestination<LastPayment, Operator, UtilityService>
    
    private typealias State = Flow<Destination>
    private typealias Event = UtilityFlowEvent<LastPayment, Operator, UtilityService, StartPaymentResponse>
    private typealias Effect = UtilityFlowEffect<LastPayment, Operator, UtilityService>
    
    private typealias LoaderSpy = Spy<Void, SUT.LoadResult>
    private typealias PaymentStarterSpy = Spy<SUT.StartPaymentPayload, SUT.StartPaymentResult>
    private typealias ServicesLoaderSpy = Spy<SUT.LoadServicesPayload, SUT.LoadServicesResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        loader: LoaderSpy,
        servicesLoader: ServicesLoaderSpy,
        paymentStarter: PaymentStarterSpy
    ) {
        let loader = LoaderSpy()
        let servicesLoader = ServicesLoaderSpy()
        let paymentStarter = PaymentStarterSpy()
        
        let sut = SUT(
            load: loader.process,
            loadServices: servicesLoader.process,
            startPayment: paymentStarter.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(servicesLoader, file: file, line: line)
        trackForMemoryLeaks(paymentStarter, file: file, line: line)
        
        return (sut, loader, servicesLoader, paymentStarter)
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
