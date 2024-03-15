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
        
        let (_,_, loader) = makeSUT()
        
        XCTAssertEqual(loader.callCount, 0)
    }
    
    func test_loadFailureFlow() {
        
        let (sut, spy, loader) = makeSUT()
        
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
        let (sut, spy, loader) = makeSUT()
        
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
    
    private typealias Destination = UtilityDestination<LastPayment, Operator>
    
    private typealias State = Flow<Destination>
    private typealias Event = UtilityFlowEvent<LastPayment, Operator, StartPaymentResponse>
    private typealias Effect = UtilityFlowEffect<LastPayment, Operator>
    
    private typealias Options = Destination.Prepayment.Options
    
    private typealias Reducer = UtilityFlowReducer<LastPayment, Operator, StartPaymentResponse>
    private typealias EffectHandler = UtilityFlowEffectHandler<LastPayment, Operator, StartPaymentResponse>
    
    private typealias StateSpy = ValueSpy<State>
    
    private typealias LoaderSpy = Spy<Void, EffectHandler.LoadResult>
    private typealias PaymentStarterSpy = Spy<EffectHandler.StartPaymentPayload, EffectHandler.StartPaymentResult>
    
    private func makeSUT(
        initialState: State = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy,
        loader: LoaderSpy
    ) {
        let reducer = Reducer()
        
        let loader = LoaderSpy()
        let paymentStarter = PaymentStarterSpy()
        let effectHandler = EffectHandler(
            load: loader.process,
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
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, spy, loader)
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
