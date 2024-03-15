//
//  PaymentsTransfersIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

final class PaymentsTransfersIntegrationTests: XCTestCase {
    
    // MARK: - back
    
    func test_back_shouldNotChangeNilRouteState() {
        
        let (sut, spy, _) = makeSUT(initialRoute: nil)
        
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
        let (sut, spy, utilityEffectHandler) = makeSUT(initialRoute: nil)
        
        sut.event(.utilityFlow(.initiate))
        utilityEffectHandler.complete(with: .loaded(.failure))
        
        sut.event(.back)
        
        sut.event(.utilityFlow(.initiate))
        utilityEffectHandler.complete(with: .loaded(.success([lastPayment], operators)))
        
        sut.event(.utilityFlow(.select(lastPayment)))
        assert(
            spy,
            .init(route: nil), {
                _ in
            }, {
                $0.route = .utilityFlow(.init())
            }, {
                $0.route = .utilityFlow(.init(stack: [.prepayment(.failure)]))
            }, {
                $0.route = nil
            }, {
                $0.route = .utilityFlow(.init())
            }, {
                $0.route = .utilityFlow(.init(stack: [prepayment]))
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
        let (sut, spy, utilityEffectHandler) = makeSUT(initialRoute: nil)
        
        sut.event(.utilityFlow(.initiate))
        utilityEffectHandler.complete(with: .loaded(.failure))
        
        sut.event(.back)
        
        sut.event(.utilityFlow(.initiate))
        utilityEffectHandler.complete(with: .loaded(.success([lastPayment], operators)))
        
        assert(
            spy,
            .init(route: nil), {
                _ in
            }, {
                $0.route = .utilityFlow(.init())
            }, {
                $0.route = .utilityFlow(.init(stack: [.prepayment(.failure)]))
            }, {
                $0.route = nil
            }, {
                $0.route = .utilityFlow(.init())
            }, {
                $0.route = .utilityFlow(.init(stack: [prepayment]))
            }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    
    private typealias Reducer = PaymentsTransfersReducer<LastPayment, Operator, StartPaymentResponse>
    private typealias UtilityReducer = UtilityFlowReducer<LastPayment, Operator, StartPaymentResponse>
    
    private typealias EffectHandler = PaymentsTransfersEffectHandler<LastPayment, Operator, StartPaymentResponse>
    
    private typealias UtilityFlowEffectHandleSpy = EffectHandlerSpy<UtilityEvent, UtilityEffect>
    private typealias UtilityEvent = UtilityFlowEvent<LastPayment, Operator, StartPaymentResponse>
    private typealias UtilityEffect = UtilityFlowEffect<LastPayment>
    
    private typealias Destination = UtilityDestination<LastPayment, Operator>
    
    private typealias StateSpy = ValueSpy<State>
    
    private typealias State = PaymentsTransfersState<Destination>
    private typealias Event = PaymentsTransfersEvent<LastPayment, Operator, StartPaymentResponse>
    private typealias Effect = PaymentsTransfersEffect<LastPayment>
    
    private func makeSUT(
        initialRoute: State.Route? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy,
        utilityEffectHandler: UtilityFlowEffectHandleSpy
    ) {
        let utilityReducer = UtilityReducer()
        let reducer = Reducer(
            utilityReduce: utilityReducer.reduce(_:_:)
        )
        
        let utilityEffectHandler = UtilityFlowEffectHandleSpy()
        
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
        
        return (sut, spy, utilityEffectHandler)
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
