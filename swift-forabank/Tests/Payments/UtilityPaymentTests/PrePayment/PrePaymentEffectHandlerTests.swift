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
    
    enum Payload {
        
        case last(LastPayment)
        case service(Operator, Service)
    }
    
    typealias StartPaymentResult = Result<Response, ServiceFailure>
    typealias StartPaymentCompletion = (StartPaymentResult) -> Void
    typealias StartPayment = (Payload, @escaping StartPaymentCompletion) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PrePaymentEvent<LastPayment, Operator, Response, Service>
    typealias Effect = PrePaymentEffect<LastPayment, Operator>
}

extension PrePaymentEffectHandler.Payload: Equatable where LastPayment: Equatable, Operator: Equatable, Service: Equatable {}

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
        startPayment(.last(lastPayment)) { [weak self] in
            
            self?.handleStartPayment(result: $0, dispatch)
        }
    }
    
    func handleStartPayment(
        result: StartPaymentResult,
        _ dispatch: @escaping Dispatch
    ) {
        switch result {
        case let .failure(serviceFailure):
            dispatch(.paymentStarted(.failure(serviceFailure)))
            
        case let .success(response):
            dispatch(.paymentStarted(.success(response)))
        }
    }
    
    func selectOperator(
        _ `operator`: Operator,
        _ dispatch: @escaping Dispatch
    ) {
        loadServices(`operator`) { [weak self] in
            
            switch $0 {
            case .failure:
                dispatch(.loaded(.failure))
                
            case let .success(services):
                switch services.count {
                case 0:
                    dispatch(.loaded(.failure))
                    
                case 1:
#warning("remove bang")
                    self?.startPayment(.service(`operator`, services.first!)) { [weak self] in
                        
                        self?.handleStartPayment(result: $0, dispatch)
                    }
                    
                default:
                    dispatch(.loaded(.list(services)))
                }
            }
        }
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
        
        let effect: Effect = .select(.operator(makeOperator()))
        let services = [makeUtilityService(), makeUtilityService()]
        let (sut, _, loadServices) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .loaded(.list(services)), on: {
            
            loadServices.complete(with: .success(services))
        })
        XCTAssertEqual(services.count, 2)
    }
    
    func test_select_shouldCallStartPaymentOnLoadServicesSuccessWithOneService_operator() {
        
        let `operator` = makeOperator()
        let effect: Effect = .select(.operator(`operator`))
        let service = makeUtilityService()
        let (sut, startPayment, loadServices) = makeSUT()
        
        sut.handleEffect(effect) { _ in }
        loadServices.complete(with: .success([service]))
        
        XCTAssertNoDiff(startPayment.payloads, [.service(`operator`, service)])
    }
    
    func test_select_shouldDeliverConnectivityErrorOnStartPaymentConnectivityErrorFailureOnLoadServicesSuccessWithOneService_operator() {
        
        let effect: Effect = .select(.operator(makeOperator()))
        let service = makeUtilityService()
        let (sut, startPayment, loadServices) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .paymentStarted(.failure(.connectivityError)), on: {
            
            loadServices.complete(with: .success([service]))
            startPayment.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_select_shouldDeliverServerErrorOnStartPaymentServerErrorFailureOnLoadServicesSuccessWithOneService_operator() {
        
        let effect: Effect = .select(.operator(makeOperator()))
        let service = makeUtilityService()
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
        let service = makeUtilityService()
        let (sut, startPayment, loadServices) = makeSUT()
        
        expect(sut, with: effect, toDeliver: .paymentStarted(.success(response)), on: {
            
            loadServices.complete(with: .success([service]))
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
