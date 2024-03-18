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
        
        let (_,_, optionsLoader, servicesLoader, paymentStarter) = makeSUT()
        
        XCTAssertEqual(optionsLoader.callCount, 0)
        XCTAssertEqual(servicesLoader.callCount, 0)
        XCTAssertEqual(paymentStarter.callCount, 0)
    }
    
    func test_loadOptionsFailureFlow() {
        
        let (sut, spy, optionsLoader, servicesLoader, paymentStarter) = makeSUT()
        
        sut.event(.initiatePrepayment)
        optionsLoader.complete(with: .failure(anyError()))
        
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
        let (`operator`, operators) = makeOperatorOperators()
        let options = Options(lastPayments: lastPayments, operators: operators)
        let (sut, spy, optionsLoader, servicesLoader, paymentStarter) = makeSUT()
        
        sut.event(.initiatePrepayment)
        optionsLoader.complete(with: .success((lastPayments, operators)))
        
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
    
    private typealias State = UtilityFlow
    private typealias Event = UtilityEvent
    private typealias Effect = UtilityEffect
    
    private typealias Options = Destination.Prepayment.Options
    
    private typealias Reducer = UtilityReducer
    private typealias EffectHandler = UtilityEffectHandler
    
    private typealias StateSpy = ValueSpy<State>
    
    private typealias OptionsLoaderSpy = Spy<Void, EffectHandler.LoadOptionsResult>
    private typealias ServicesLoaderSpy = Spy<EffectHandler.LoadServicesPayload, EffectHandler.LoadServicesResult>
    private typealias PaymentStarterSpy = Spy<EffectHandler.StartPaymentPayload, EffectHandler.StartPaymentResult>
    
    private func makeSUT(
        initialState: State = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy,
        optionsLoader: OptionsLoaderSpy,
        servicesLoader: ServicesLoaderSpy,
        paymentStarter: PaymentStarterSpy
    ) {
        let reducer = Reducer()
        
        let optionsLoader = OptionsLoaderSpy()
        let servicesLoader = ServicesLoaderSpy()
        let paymentStarter = PaymentStarterSpy()

        let effectHandler = EffectHandler(
            loadOptions: optionsLoader.process,
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
        trackForMemoryLeaks(optionsLoader, file: file, line: line)
        trackForMemoryLeaks(servicesLoader, file: file, line: line)
        trackForMemoryLeaks(paymentStarter, file: file, line: line)
        
        return (sut, spy, optionsLoader, servicesLoader, paymentStarter)
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
