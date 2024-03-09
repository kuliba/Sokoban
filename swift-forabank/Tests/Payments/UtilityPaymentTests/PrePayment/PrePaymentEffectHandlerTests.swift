//
//  PrePaymentEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 09.03.2024.
//

import PrePaymentPicker
import UtilityPayment
import XCTest

typealias ServiceFailure = UtilityPayment.ServiceFailure

final class PrePaymentEffectHandler<LastPayment, Operator, Response, Service> {
    
    private let loadServices: LoadServices
    private let startPayment: StartPayment
    
    init(
        loadServices: @escaping LoadServices,
        startPayment: @escaping StartPayment
    ) {
        self.loadServices = loadServices
        self.startPayment = startPayment
    }
}

extension PrePaymentEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
            handleSelect(select, dispatch)
        }
    }
}

extension PrePaymentEffectHandler {
    
    typealias LoadServicesPayload = Operator
    typealias LoadServicesResult = Result<[Service], Error>
    typealias LoadServicesCompletion = (LoadServicesResult) -> Void
    typealias LoadServices = (LoadServicesPayload, @escaping LoadServicesCompletion) -> Void
    
    typealias Payload = Effect.Select
    typealias StartPaymentResult = Result<Response, ServiceFailure>
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    typealias StartPayment = (Payload, @escaping StartPaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PrePaymentEvent<LastPayment, Operator, Response, Service>
    typealias Effect = PrePaymentEffect<LastPayment, Operator>
}

private extension PrePaymentEffectHandler {
    
    func handleSelect(
        _ select: Effect.Select,
        _ dispatch: @escaping Dispatch
    ) {
        switch select {
        case let .last(lastPayment):
            selectLastPayment(lastPayment, dispatch)
            
        case let .operator(`operator`):
            selectOperator(`operator`, dispatch)
        }
    }
    
    func selectLastPayment(
        _ lastPayment: LastPayment,
        _ dispatch: @escaping Dispatch
    ) {
        startPayment(.last(lastPayment)) {
            
            switch $0 {
            case let .failure(serviceFailure):
                dispatch(.paymentStarted(.failure(serviceFailure)))
                
            case let .success(response):
                dispatch(.paymentStarted(.success(response)))
            }
        }
    }
    
    func selectOperator(
        _ `operator`: Operator,
        _ dispatch: @escaping Dispatch
    ) {
        fatalError("can't handle `operator` case with \(`operator`) - can't start payment, need to select service first")
    }
}

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
    
    // MARK: - Helpers
    
    private typealias SUT = PrePaymentEffectHandler<LastPayment, Operator, StartPaymentResponse, UtilityService>
    
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias StartPaymentSpy = Spy<SUT.Payload, SUT.StartPaymentResult>
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
    
    private func makeLastPayment(
        _ value: String = UUID().uuidString
    ) -> LastPayment {
        
        .init(value: value)
    }
    
    private func makeOperator(
        _ value: String = UUID().uuidString
    ) -> Operator {
        
        .init(value: value)
    }
    
    private func makeResponse(
        _ value: String = UUID().uuidString
    ) -> StartPaymentResponse {
        
        .init(value: value)
    }
    
    private func makeUtilityService(
        _ value: String = UUID().uuidString
    ) -> UtilityService {
        
        .init(value: value)
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

private struct LastPayment: Equatable {
    
    var value: String
}

private struct Operator: Equatable, Identifiable {
    
    var value: String
    
    var id: String { value }
}

private struct StartPaymentResponse: Equatable {
    
    var value: String
    
    var id: String { value }
}

private struct UtilityService: Equatable {
    
    var value: String
    
    var id: String { value }
}
