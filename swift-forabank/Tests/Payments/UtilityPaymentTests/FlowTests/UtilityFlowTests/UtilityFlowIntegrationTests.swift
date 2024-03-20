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
        
        let (_,_, operatorsLoader, optionsLoader, servicesLoader, paymentStarter) = makeSUT()
        
        XCTAssertEqual(operatorsLoader.callCount, 0)
        XCTAssertEqual(optionsLoader.callCount, 0)
        XCTAssertEqual(servicesLoader.callCount, 0)
        XCTAssertEqual(paymentStarter.callCount, 0)
    }
    
    func test_loadOptionsFailureFlow() {
        
        let (sut, spy, operatorsLoader, optionsLoader, servicesLoader, paymentStarter) = makeSUT()
        
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
        let (sut, spy, operatorsLoader, optionsLoader, servicesLoader, paymentStarter) = makeSUT()
        
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
        
    private func makeSUT(
        initialState: State = .init(),
        ppoStub: [(PPOState, PPOEffect?)] = [makePPOStub()],
        debounce: DispatchTimeInterval = .never,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy,
        operatorsLoader: LoadOperatorsSpy,
        optionsLoader: OptionsLoaderSpy,
        servicesLoader: ServicesLoaderSpy,
        paymentStarter: PaymentStarterSpy
    ) {
        let scheduler: AnySchedulerOfDispatchQueue = .immediate
        
        let ppoReducer = PPOReducer(stub: ppoStub)
        let reducer = Reducer(ppoReduce: ppoReducer.reduce(_:_:))
        
        let operatorsLoader = LoadOperatorsSpy()
        let optionsEffectHandler = OptionsEffectHandler(
            debounce: debounce,
            loadOperators: operatorsLoader.process,
            scheduler: scheduler
        )
        
        let optionsLoader = OptionsLoaderSpy()
        let servicesLoader = ServicesLoaderSpy()
        let paymentStarter = PaymentStarterSpy()

        let effectHandler = EffectHandler(
            loadPrepaymentOptions: optionsLoader.process,
            loadServices: servicesLoader.process,
            optionsEffectHandle: optionsEffectHandler.handleEffect,
            startPayment: paymentStarter.process
        )
        
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
        
        let spy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(reducer, file: file, line: line)
        trackForMemoryLeaks(effectHandler, file: file, line: line)
        trackForMemoryLeaks(operatorsLoader, file: file, line: line)
        trackForMemoryLeaks(optionsLoader, file: file, line: line)
        trackForMemoryLeaks(servicesLoader, file: file, line: line)
        trackForMemoryLeaks(paymentStarter, file: file, line: line)
        
        return (sut, spy, operatorsLoader, optionsLoader, servicesLoader, paymentStarter)
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
