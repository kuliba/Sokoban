//
//  PrePaymentEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 09.03.2024.
//

import PrePaymentPicker
import UtilityPayment
import XCTest

final class PrePaymentEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, startPayment, loadServices) = makeSUT()
        
        XCTAssertEqual(startPayment.callCount, 0)
        XCTAssertEqual(loadServices.callCount, 0)
    }
    
    // MARK: - select lastPayment
    
    func test_select_shouldCallStartPayment_lastPayment() {
        
        let lastPayment = makeLastPayment()
        let effect: Effect = .select(.last(lastPayment))
        let (sut, startPayment, _) = makeSUT()
        
        sut.handleEffect(effect) { _ in }
        
        XCTAssertNoDiff(startPayment.payloads, [.last(lastPayment)])
    }
    
    func test_select_shouldDeliverConnectivityErrorOnStartPaymentConnectivityErrorFailure_lastPayment() {
        
        let effect: Effect = .select(.last(makeLastPayment()))
        let (sut, startPayment, _) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .paymentStarted(.failure(.connectivityError)), on: {
            
            startPayment.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_select_shouldDeliverServerErrorOnStartPaymentServerErrorFailure_lastPayment() {
        
        let effect: Effect = .select(.last(makeLastPayment()))
        let message = anyMessage()
        let (sut, startPayment, _) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .paymentStarted(.failure(.serverError(message))), on: {
            
            startPayment.complete(with: .failure(.serverError(message)))
        })
    }
    
    func test_select_shouldDeliverStartPaymentResponseOnSuccess_lastPayment() {
        
        let effect: Effect = .select(.last(makeLastPayment()))
        let response = makeResponse()
        let (sut, startPayment, _) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .paymentStarted(.success(response)), on: {
            
            startPayment.complete(with: .success(response))
        })
    }
    
    // MARK: - select operator
    
    func test_select_shouldCallLoadServicesWithOperator_operator() {
        
        let `operator` = makeOperator()
        let effect: Effect = .select(.operator(`operator`))
        let (sut, _, loadServices) = makeSUT()
        
        sut.handleEffect(effect) { _ in }
        
        XCTAssertNoDiff(loadServices.payloads, [`operator`])
    }
    
    func test_select_shouldDeliverFailureOnLoadServicesFailure_operator() {
        
        let effect: Effect = .select(.operator(makeOperator()))
        let (sut, _, loadServices) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .loaded(.failure), on: {
            
            loadServices.complete(with: .failure(anyError()))
        })
    }
    
    func test_select_shouldDeliverFailureOnLoadServicesSuccessWithEmptyList_operator() {
        
        let effect: Effect = .select(.operator(makeOperator()))
        let (sut, _, loadServices) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .loaded(.failure), on: {
            
            loadServices.complete(with: .success([]))
        })
    }
    
    func test_select_shouldDeliverServicesListOnLoadServicesSuccessWithMoreThanOneService_operator() {
        
        let `operator` = makeOperator()
        let effect: Effect = .select(.operator(`operator`))
        let services = [makeService(), makeService()]
        let (sut, _, loadServices) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .loaded(.list(`operator`, services)), on: {
            
            loadServices.complete(with: .success(services))
        })
        XCTAssertEqual(services.count, 2)
    }
    
    func test_select_shouldCallStartPaymentOnLoadServicesSuccessWithOneService_operator() {
        
        let `operator` = makeOperator()
        let effect: Effect = .select(.operator(`operator`))
        let service = makeService()
        let (sut, startPayment, loadServices) = makeSUT()
        
        sut.handleEffect(effect) { _ in }
        loadServices.complete(with: .success([service]))
        
        XCTAssertNoDiff(startPayment.payloads, [.service(`operator`, service)])
    }
    
    func test_select_shouldDeliverConnectivityErrorOnStartPaymentConnectivityErrorFailureOnLoadServicesSuccessWithOneService_operator() {
        
        let effect: Effect = .select(.operator(makeOperator()))
        let service = makeService()
        let (sut, startPayment, loadServices) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .paymentStarted(.failure(.connectivityError)), on: {
            
            loadServices.complete(with: .success([service]))
            startPayment.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_select_shouldDeliverServerErrorOnStartPaymentServerErrorFailureOnLoadServicesSuccessWithOneService_operator() {
        
        let effect: Effect = .select(.operator(makeOperator()))
        let service = makeService()
        let message = anyMessage()
        let (sut, startPayment, loadServices) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .paymentStarted(.failure(.serverError(message))), on: {
            
            loadServices.complete(with: .success([service]))
            startPayment.complete(with: .failure(.serverError(message)))
        })
    }
    
    func test_select_shouldDeliverStartPaymentResponseOnSuccessOnLoadServicesSuccessWithOneService_operator() {
        
        let effect: Effect = .select(.operator(makeOperator()))
        let response = makeResponse()
        let service = makeService()
        let (sut, startPayment, loadServices) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .paymentStarted(.success(response)), on: {
            
            loadServices.complete(with: .success([service]))
            startPayment.complete(with: .success(response))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = PrePaymentEffectHandler<LastPayment, Operator, StartPaymentResponse, Service>
    
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias StartPaymentSpy = Spy<SUT.StartPaymentPayload, SUT.StartPaymentResult>
    private typealias LoadServicesSpy = Spy<SUT.LoadServicesPayload, SUT.LoadServicesResult>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        startPayment: StartPaymentSpy,
        loadServices: LoadServicesSpy
    ) {
        let startPayment = StartPaymentSpy()
        let loadServices = LoadServicesSpy()
        let sut = SUT(
            loadServices: loadServices.process,
            startPayment: startPayment.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(startPayment, file: file, line: line)
        trackForMemoryLeaks(loadServices, file: file, line: line)
        
        return (sut, startPayment, loadServices)
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
