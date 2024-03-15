//
//  PaymentsTransfersIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

private typealias SUT = RxViewModel<State, Event, Effect>

private typealias State = PaymentsTransfersState<Destination>
private typealias Event = PaymentsTransfersEvent<LastPayment, Operator, StartPaymentResponse>
private typealias Effect = PaymentsTransfersEffect<LastPayment>

//private typealias Destination = UtilityDestination<LastPayment, Operator>

private typealias StateSpy = ValueSpy<State>

private typealias Reducer = PaymentsTransfersReducer<LastPayment, Operator, StartPaymentResponse>

private typealias UtilityReducer = UtilityFlowReducer<LastPayment, Operator, StartPaymentResponse>

private typealias EffectHandler = PaymentsTransfersEffectHandler<LastPayment, Operator, StartPaymentResponse>

private typealias UtilityEffectHandler = UtilityFlowEffectHandler<LastPayment, Operator, StartPaymentResponse>
private typealias LoaderSpy = Spy<Void, UtilityEffectHandler.LoadResult>
private typealias PaymentStarterSpy = Spy<UtilityEffectHandler.StartPaymentPayload, UtilityEffectHandler.StartPaymentResult>

final class PaymentsTransfersIntegrationTests: XCTestCase {
    
    // MARK: - back
    
    func test_back_shouldNotChangeNilRouteState() {
        
        let (sut, spy, _,_) = makeSUT(initialRoute: nil)
        
        sut.event(.back)
        sut.event(.back)
        sut.event(.back)
        
        assert(
            spy,
            .init(route: nil), {
                _ in
            }, {
                _ in
            }
        )
    }
    
    func test_startPaymentFailureFlow() {
        
        let lastPayment = makeLastPayment()
        let `operator` = makeOperator()
        let operators = [`operator`, makeOperator()]
        let prepayment = Destination.prepayment(.options(.init(
            lastPayments: [lastPayment],
            operators: operators
        )))
        let (sut, spy, loader, paymentStarter) = makeSUT(initialRoute: nil)
        
        sut.event(.utilityFlow(.initiate))
        loader.complete(with: .failure(anyError()))
        
        sut.event(.back)
        
        sut.event(.utilityFlow(.initiate))
        loader.complete(with: .success(([lastPayment], operators)), at: 1)
        
        sut.event(.utilityFlow(.select(.last(lastPayment))))
        paymentStarter.complete(with: .failure(.connectivityError))
        
        assert(
            spy,
            .init(route: nil), {
                _ in
            }, {
                $0.route = emptyUtilityFlow()
            }, {
                $0.route = utilityFlow(.prepayment(.failure))
            }, {
                $0.route = nil
            }, {
                $0.route = emptyUtilityFlow()
            }, {
                $0.route = utilityFlow(prepayment)
            }, {
                $0.route = utilityFlow(prepayment, .failure(.connectivityError))
            }
        )
    }
    
    func test_startPaymentSuccessFlow() {
        
        let lastPayment = makeLastPayment()
        let `operator` = makeOperator()
        let operators = [`operator`, makeOperator()]
        let prepayment = Destination.prepayment(.options(.init(
            lastPayments: [lastPayment],
            operators: operators
        )))
        let (sut, spy, loader, paymentStarter) = makeSUT(initialRoute: nil)
        
        sut.event(.utilityFlow(.initiate))
        loader.complete(with: .failure(anyError()))
        
        sut.event(.back)
        
        sut.event(.utilityFlow(.initiate))
        loader.complete(with: .success(([lastPayment], operators)), at: 1)
        
        sut.event(.utilityFlow(.select(.last(lastPayment))))
        paymentStarter.complete(with: .success(makeResponse()))
        
        sut.event(.back)
        
        assert(
            spy,
            .init(route: nil), {
                _ in
            }, {
                $0.route = emptyUtilityFlow()
            }, {
                $0.route = utilityFlow(.prepayment(.failure))
            }, {
                $0.route = nil
            }, {
                $0.route = emptyUtilityFlow()
            }, {
                $0.route = utilityFlow(prepayment)
            }, {
                $0.route = utilityFlow(prepayment, .payment)
            }, {
                $0.route = utilityFlow(prepayment)
            }
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        initialRoute: State.Route? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy,
        loader: LoaderSpy,
        paymentStarter: PaymentStarterSpy
    ) {
        let utilityReducer = UtilityReducer()
        let reducer = Reducer(
            utilityReduce: utilityReducer.reduce(_:_:)
        )
        
        let paymentStarter = PaymentStarterSpy()
        let loader = LoaderSpy()
        let utilityEffectHandler = UtilityEffectHandler(
            load: loader.process,
            startPayment: paymentStarter.process
        )
        
        let effectHandler = EffectHandler(
            utilityFlowHandleEffect: utilityEffectHandler.handleEffect(_:_:)
        )
        
        let sut = SUT(
            initialState: .init(route: initialRoute),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .immediate
        )
        
        let spy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(reducer, file: file, line: line)
        trackForMemoryLeaks(effectHandler, file: file, line: line)
        trackForMemoryLeaks(utilityEffectHandler, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(paymentStarter, file: file, line: line)
        
        return (sut, spy, loader, paymentStarter)
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

private func emptyUtilityFlow() -> State.Route {
    
    .utilityFlow(.init())
}

private func utilityFlow(
    _ destinations: Destination...
) -> State.Route {
    
    .utilityFlow(.init(stack: .init(destinations)))
}
