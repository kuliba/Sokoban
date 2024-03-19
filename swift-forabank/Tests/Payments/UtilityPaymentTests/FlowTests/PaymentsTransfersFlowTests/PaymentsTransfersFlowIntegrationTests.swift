//
//  PaymentsTransfersFlowIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import RxViewModel
import UtilityPayment
import XCTest

final class PaymentsTransfersFlowIntegrationTests: XCTestCase {
    
    // MARK: - back
    
    func test_back_shouldNotChangeNilRouteState() {
        
        let (sut, spy, _,_,_) = makeSUT(initialRoute: nil)
        
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
    
    func test_restartLoadOptionsFailureFlow() {
        
        let lastPayment = makeLastPayment()
        let (_, operators) = makeOperatorOperators()
        let prepayment = makePrepayment([lastPayment], operators)
        let (sut, spy, optionsLoader, _,_) = makeSUT(initialRoute: nil)
        
        sut.event(.utilityFlow(.initiate))
        optionsLoader.complete(with: .failure(anyError()))
        
        sut.event(.back)
        
        sut.event(.utilityFlow(.initiate))
        optionsLoader.complete(with: .success(([lastPayment], operators)), at: 1)
        
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
            }
        )
    }
    
    func test_startPaymentWithLastPaymentFailureFlow() {
        
        let lastPayment = makeLastPayment()
        let (_, operators) = makeOperatorOperators()
        let prepayment = makePrepayment([lastPayment], operators)
        let (sut, spy, optionsLoader, _, paymentStarter) = makeSUT(initialRoute: nil)
        
        sut.event(.utilityFlow(.initiate))
        optionsLoader.complete(with: .success(([lastPayment], operators)))
        
        sut.event(.utilityFlow(.select(.last(lastPayment))))
        paymentStarter.complete(with: .failure(.connectivityError))
        
        assert(
            spy,
            .init(route: nil), {
                _ in
            }, {
                $0.route = emptyUtilityFlow()
            }, {
                $0.route = utilityFlow(prepayment)
            }, {
                $0.route = utilityFlow(prepayment, .failure(.connectivityError))
            }
        )
    }
    
    func test_noServiceOperatorFailureFlow() {
        
        let lastPayment = makeLastPayment()
        let (`operator`, operators) = makeOperatorOperators()
        let prepayment = makePrepayment([lastPayment], operators)
        let (sut, spy, optionsLoader, servicesLoader, _) = makeSUT(initialRoute: nil)
        
        sut.event(.utilityFlow(.initiate))
        optionsLoader.complete(with: .success(([lastPayment], operators)))
        
        sut.event(.utilityFlow(.select(.operator(`operator`))))
        servicesLoader.complete(with: .success([]))
        
        assert(
            spy,
            .init(route: nil), {
                _ in
            }, {
                $0.route = emptyUtilityFlow()
            }, {
                $0.route = utilityFlow(prepayment)
            }, {
                $0.route = utilityFlow(prepayment, .selectFailure(`operator`))
            }
        )
    }
    
    func test_startPaymentWithSingleServiceOperatorFailureFlow() {
        
        let lastPayment = makeLastPayment()
        let (`operator`, operators) = makeOperatorOperators()
        let prepayment = makePrepayment([lastPayment], operators)
        let service = makeService()
        let (sut, spy, optionsLoader, servicesLoader, paymentStarter) = makeSUT(initialRoute: nil)
        
        sut.event(.utilityFlow(.initiate))
        optionsLoader.complete(with: .success(([lastPayment], operators)))
        
        sut.event(.utilityFlow(.select(.operator(`operator`))))
        servicesLoader.complete(with: .success([service]))
        paymentStarter.complete(with: .failure(.connectivityError))
        
        assert(
            spy,
            .init(route: nil), {
                _ in
            }, {
                $0.route = emptyUtilityFlow()
            }, {
                $0.route = utilityFlow(prepayment)
            }, {
                $0.route = utilityFlow(prepayment, .failure(.connectivityError))
            }
        )
    }
    
    func test_startPaymentWithMultiServiceOperatorFailureFlow() {
        
        let lastPayment = makeLastPayment()
        let (`operator`, operators) = makeOperatorOperators()
        let prepayment = makePrepayment([lastPayment], operators)
        let (service, services) = makeServiceServices()
        let (sut, spy, optionsLoader, servicesLoader, paymentStarter) = makeSUT(initialRoute: nil)
        
        sut.event(.utilityFlow(.initiate))
        optionsLoader.complete(with: .success(([lastPayment], operators)))
        
        sut.event(.utilityFlow(.select(.operator(`operator`))))
        servicesLoader.complete(with: .success(services))
        
        sut.event(.utilityFlow(.select(.service(service, for: `operator`))))
        paymentStarter.complete(with: .failure(.connectivityError))
        
        assert(
            spy,
            .init(route: nil), {
                _ in
            }, {
                $0.route = emptyUtilityFlow()
            }, {
                $0.route = utilityFlow(prepayment)
            }, {
                $0.route = utilityFlow(prepayment, .services(services))
            }, {
                $0.route = utilityFlow(prepayment, .services(services), .failure(.connectivityError))
            }
        )
    }
    
    func test_startPaymentWithLastPaymentSuccessFlow() {
        
        let lastPayment = makeLastPayment()
        let (_, operators) = makeOperatorOperators()
        let prepayment = makePrepayment([lastPayment], operators)
        let (sut, spy, optionsLoader, _, paymentStarter) = makeSUT(initialRoute: nil)
        
        sut.event(.utilityFlow(.initiate))
        optionsLoader.complete(with: .success(([lastPayment], operators)))
        
        sut.event(.utilityFlow(.select(.last(lastPayment))))
        paymentStarter.complete(with: .success(makeResponse()))
        
        sut.event(.back)
        sut.event(.back)
        
        assert(
            spy,
            .init(route: nil), {
                _ in
            }, {
                $0.route = emptyUtilityFlow()
            }, {
                $0.route = utilityFlow(prepayment)
            }, {
                $0.route = utilityFlow(prepayment, .payment)
            }, {
                $0.route = utilityFlow(prepayment)
            }, {
                $0.route = nil
            }
        )
    }
    
    func test_startPaymentWithSingleServiceOperatorSuccessFlow() {
        
        let lastPayment = makeLastPayment()
        let (`operator`, operators) = makeOperatorOperators()
        let prepayment = makePrepayment([lastPayment], operators)
        let service = makeService()
        let (sut, spy, optionsLoader, servicesLoader, paymentStarter) = makeSUT(initialRoute: nil)
        
        sut.event(.utilityFlow(.initiate))
        optionsLoader.complete(with: .success(([lastPayment], operators)))
        
        sut.event(.utilityFlow(.select(.operator(`operator`))))
        servicesLoader.complete(with: .success([service]))
        paymentStarter.complete(with: .success(makeResponse()))
        
        sut.event(.back)
        sut.event(.back)
        
        assert(
            spy,
            .init(route: nil), {
                _ in
            }, {
                $0.route = emptyUtilityFlow()
            }, {
                $0.route = utilityFlow(prepayment)
            }, {
                $0.route = utilityFlow(prepayment, .payment)
            }, {
                $0.route = utilityFlow(prepayment)
            }, {
                $0.route = nil
            }
        )
    }
    
    func test_startPaymentWithMultiServiceOperatorSuccessFlow() {
        
        let lastPayment = makeLastPayment()
        let (`operator`, operators) = makeOperatorOperators()
        let prepayment = makePrepayment([lastPayment], operators)
        let (service, services) = makeServiceServices()
        let (sut, spy, optionsLoader, servicesLoader, paymentStarter) = makeSUT(initialRoute: nil)
        
        sut.event(.utilityFlow(.initiate))
        optionsLoader.complete(with: .success(([lastPayment], operators)))
        
        sut.event(.utilityFlow(.select(.operator(`operator`))))
        servicesLoader.complete(with: .success(services))
        
        sut.event(.utilityFlow(.select(.service(service, for: `operator`))))
        paymentStarter.complete(with: .success(makeResponse()))
        
        sut.event(.back)
        sut.event(.back)
        sut.event(.back)
        
        assert(
            spy,
            .init(route: nil), {
                _ in
            }, {
                $0.route = emptyUtilityFlow()
            }, {
                $0.route = utilityFlow(prepayment)
            }, {
                $0.route = utilityFlow(prepayment, .services(services))
            }, {
                $0.route = utilityFlow(prepayment, .services(services), .payment)
            }, {
                $0.route = utilityFlow(prepayment, .services(services))
            }, {
                $0.route = utilityFlow(prepayment)
            }, {
                $0.route = nil
            }
        )
    }
    
#warning("add payment flow")
    
    // MARK: - Helpers
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    
    private typealias State = PaymentsTransfersFlowState<Destination>
    private typealias Event = PaymentsTransfersFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
    private typealias Effect = PaymentsTransfersFlowEffect<LastPayment, Operator, Service>
    
    private typealias StateSpy = ValueSpy<State>
    
    private typealias Reducer = PaymentsTransfersFlowReducer<LastPayment, Operator, Service, StartPaymentResponse>
    
    private typealias EffectHandler = PaymentsTransfersFlowEffectHandler<LastPayment, Operator, Service, StartPaymentResponse>
    
    private typealias OptionsLoaderSpy = Spy<Void, UtilityEffectHandler.LoadOptionsResult>
    private typealias ServicesLoaderSpy = Spy<UtilityEffectHandler.LoadServicesPayload, UtilityEffectHandler.LoadServicesResult>
    private typealias PaymentStarterSpy = Spy<UtilityEffectHandler.StartPaymentPayload, UtilityEffectHandler.StartPaymentResult>
    
    private func makeSUT(
        initialRoute: State.Route? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: StateSpy,
        optionsLoader: OptionsLoaderSpy,
        servicesLoader: ServicesLoaderSpy,
        paymentStarter: PaymentStarterSpy
    ) {
        let utilityReducer = UtilityReducer()
        let reducer = Reducer(
            utilityReduce: utilityReducer.reduce(_:_:)
        )
        
        let optionsLoader = OptionsLoaderSpy()
        let servicesLoader = ServicesLoaderSpy()
        let paymentStarter = PaymentStarterSpy()
        
        let utilityEffectHandler = UtilityEffectHandler(
            loadOptions: optionsLoader.process,
            loadServices: servicesLoader.process,
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

private func emptyUtilityFlow() -> PaymentsTransfersFlowState<Destination>.Route {
    
    .utilityFlow(.init())
}

private func utilityFlow(
    _ destinations: Destination...
) -> PaymentsTransfersFlowState<Destination>.Route {
    
    .utilityFlow(.init(stack: .init(destinations)))
}
