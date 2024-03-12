//
//  UtilityPaymentFlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 12.03.2024.
//

import PrePaymentPicker
import RxViewModel
import UtilityPayment
import XCTest

final class UtilityPaymentFlowIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, loadLastPayments, loadOperators, loadServices, startPayment) = makeSUT()
        
        XCTAssertEqual(loadLastPayments.callCount, 0)
        XCTAssertEqual(loadOperators.callCount, 0)
        XCTAssertEqual(loadServices.callCount, 0)
        XCTAssertEqual(startPayment.callCount, 0)
    }
    
    func test_loadFailureFlow() {
        
        let (sut, spy, loadLastPayments, loadOperators, _, _) = makeSUT()
        
        sut.event(.prePaymentOptions(.initiate))
        loadLastPayments.complete(with: .failure(.connectivityError))
        loadOperators.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(spy.values, [
            .init([]),
            .init([.prePaymentOptions(.init(isInflight: true))], status: .inflight),
            .init([.prePaymentOptions(.init(isInflight: false))], status: .none),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Response = StartPaymentResponse
    private typealias Service = UtilityService
    
    private typealias State = UtilityPaymentFlowState<LastPayment, Operator, Service>
    private typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, Response, Service>
    private typealias Effect = UtilityPaymentFlowEffect<LastPayment, Operator>
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    
    private typealias PPOReducer = PrePaymentOptionsReducer<LastPayment, Operator>
    
    private typealias PPOEffectHandler = PrePaymentOptionsEffectHandler<LastPayment, Operator>
    private typealias LoadLastPaymentsSpy = Spy<Void, PPOEffectHandler.LoadLastPaymentsResult>
    private typealias LoadOperatorsSpy = Spy<PPOEffectHandler.LoadOperatorsPayload?, PPOEffectHandler.LoadOperatorsResult>
    
    private typealias PPEffectHandler = PrePaymentEffectHandler<LastPayment, Operator, Response, Service>
    private typealias StartPaymentSpy = Spy<PPEffectHandler.StartPaymentPayload, PPEffectHandler.StartPaymentResult>
    private typealias LoadServicesSpy = Spy<PPEffectHandler.LoadServicesPayload, PPEffectHandler.LoadServicesResult>
    
    private typealias FlowEffectHandler = UtilityPaymentFlowEffectHandler<LastPayment, Operator, Response, Service>
    
    private func makeSUT(
        initialState: State = .init([]),
        observeLast: Int = 3,
        pageSize: Int = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: ValueSpy<State>,
        loadLastPayments: LoadLastPaymentsSpy,
        loadOperators: LoadOperatorsSpy,
        loadServices: LoadServicesSpy,
        startPayment: StartPaymentSpy
    ) {
        let ppoReducer = PPOReducer(
            observeLast: observeLast,
            pageSize: pageSize
        )
        let reducer = UtilityPaymentFlowReducer<LastPayment, Operator, Response, Service>(
            prePaymentOptionsReduce: ppoReducer.reduce(_:_:)
        )
        
        let loadLastPayments = LoadLastPaymentsSpy()
        let loadOperators = LoadOperatorsSpy()
        let ppoEffectHandler = PPOEffectHandler(
            loadLastPayments: loadLastPayments.process,
            loadOperators: loadOperators.process
        )
        
        let loadServices = LoadServicesSpy()
        let startPayment = StartPaymentSpy()
        let ppEffectHandler = PPEffectHandler(
            loadServices: loadServices.process,
            startPayment: startPayment.process
        )
        
        let effectHandler = FlowEffectHandler(
            ppoHandleEffect: ppoEffectHandler.handleEffect(_:_:),
            ppHandleEffect: ppEffectHandler.handleEffect(_:_:)
        )
        
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .immediate
        )
        
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(loadLastPayments, file: file, line: line)
        trackForMemoryLeaks(loadOperators, file: file, line: line)
        trackForMemoryLeaks(loadServices, file: file, line: line)
        trackForMemoryLeaks(startPayment, file: file, line: line)
        
        return (sut, spy, loadLastPayments, loadOperators, loadServices, startPayment)
    }
}
