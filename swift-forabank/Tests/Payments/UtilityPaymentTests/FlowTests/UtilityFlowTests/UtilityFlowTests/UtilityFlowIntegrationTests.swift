//
//  UtilityFlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

final class UtilityFlowIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, loader, servicesLoader, paymentStarter) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
        XCTAssertEqual(servicesLoader.callCount, 0)
        XCTAssertEqual(paymentStarter.callCount, 0)
    }
    
    func test_loadFailureFlow() {
        
        let (sut, spy, loader, servicesLoader, paymentStarter) = makeSUT()
        
        sut.event(.initiate)
        loader.complete(with: .failure(anyError()))
        
        assert(
            spy,
            .init(), {
                _ in
            }, {
                _ in
            }, {
                $0.push(.prepayment(.failure))
            }
        )
    }
    
    func test_flow() {
        
        let lastPayments = [makeLastPayment()]
        let `operator` = makeOperator()
        let operators = [`operator`, makeOperator()]
        let options = Options(lastPayments: lastPayments, operators: operators)
        let (sut, spy, loader, servicesLoader, paymentStarter) = makeSUT()
        
        sut.event(.initiate)
        loader.complete(with: .success((lastPayments, operators)))
        
        assert(
            spy,
            .init(), {
                _ in
            }, {
                _ in
            }, {
                $0.push(.prepayment(.options(options)))
            }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    #warning("extrat reusable test typealiases")
    private typealias Destination = UtilityDestination<LastPayment, Operator, UtilityService>
    
    private typealias State = Flow<Destination>
    private typealias Event = UtilityFlowEvent<LastPayment, Operator, UtilityService, StartPaymentResponse>
    private typealias Effect = UtilityFlowEffect<LastPayment, Operator>
    
    private typealias Options = Destination.Prepayment.Options
    
    private typealias Reducer = UtilityFlowReducer<LastPayment, Operator, UtilityService, StartPaymentResponse>
    private typealias EffectHandler = UtilityFlowEffectHandler<LastPayment, Operator, UtilityService, StartPaymentResponse>
    
    private typealias StateSpy = ValueSpy<State>
    
    private typealias LoaderSpy = Spy<Void, EffectHandler.LoadResult>
    private typealias ServicesLoaderSpy = Spy<EffectHandler.LoadServicesPayload, EffectHandler.LoadServicesResult>
    private typealias PaymentStarterSpy = Spy<EffectHandler.StartPaymentPayload, EffectHandler.StartPaymentResult>
    
    private func makeSUT(
        initialState: State = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy,
        loader: LoaderSpy,
        servicesLoader: ServicesLoaderSpy,
        paymentStarter: PaymentStarterSpy
    ) {
        let reducer = Reducer()
        
        let loader = LoaderSpy()
        let servicesLoader = ServicesLoaderSpy()
        let paymentStarter = PaymentStarterSpy()

        let effectHandler = EffectHandler(
            load: loader.process,
            loadServices: servicesLoader.process,
            startPayment: paymentStarter.process
        )
        
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .immediate
        )
        
        let spy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(reducer, file: file, line: line)
        trackForMemoryLeaks(effectHandler, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(servicesLoader, file: file, line: line)
        trackForMemoryLeaks(paymentStarter, file: file, line: line)
        
        return (sut, spy, loader, servicesLoader, paymentStarter)
        
    }
    
    private func assert(
        _ spy: StateSpy,
        _ initialState: State,
        _ updates: ((inout State) -> Void)...,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var state = initialState
        var values = [State]()
        
        for update in updates {
            
            update(&state)
            values.append(state)
        }
        
        XCTAssertNoDiff(spy.values, values, file: file, line: line)
    }
}
