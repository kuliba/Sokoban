//
//  PaymentsTransfersHelpers.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment
import XCTest

typealias Destination = UtilityDestination<LastPayment, Operator, Service>

typealias UtilityFlow = Flow<Destination>
typealias UtilityEvent = UtilityFlowEvent<LastPayment, Operator, Service, StartPaymentResponse>
typealias UtilityEffect = UtilityFlowEffect<LastPayment, Operator, Service>

typealias UtilityReducer = UtilityFlowReducer<LastPayment, Operator, Service, StartPaymentResponse>
typealias UtilityEffectHandler = UtilityFlowEffectHandler<LastPayment, Operator, Service, StartPaymentResponse>

typealias PPOReducer = ReducerSpy<PPOState, PPOEvent, PPOEffect>

typealias OptionsEffectHandler = PrepaymentOptionsEffectHandler<LastPayment, Operator>

typealias LoadOperatorsSpy = Spy<OptionsEffectHandler.LoadOperatorsPayload, OptionsEffectHandler.LoadOperatorsResult>
typealias OptionsLoaderSpy = Spy<Void, UtilityEffectHandler.LoadPrepaymentOptionsResult>
typealias PaymentStarterSpy = Spy<UtilityEffectHandler.StartPaymentPayload, UtilityEffectHandler.StartPaymentResult>
typealias ServicesLoaderSpy = Spy<UtilityEffectHandler.LoadServicesPayload, UtilityEffectHandler.LoadServicesResult>

typealias PPOState = UtilityReducer.PPOState
typealias PPOEvent = UtilityReducer.PPOEvent
typealias PPOEffect = UtilityReducer.PPOEffect

func makeEmptyUtilityFlow(
    file: StaticString = #file,
    line: UInt = #line
) -> UtilityFlow {
    
    let flow = UtilityFlow.init(stack: .init([]))
    
    XCTAssert(flow.stack.isEmpty)
    
    return flow
}

func makePrepaymentOptions(
    lastPayments: [LastPayment] = [],
    operators: [Operator] = [makeOperator()],
    searchText: String = "",
    isInflight: Bool = false
) -> Destination {
    
    .prepayment(.options(.init(
        lastPayments: lastPayments,
        operators: operators,
        searchText: searchText,
        isInflight: isInflight
    )))
}

func makeServicesDestination(
    _ services: [Service] = [makeService(), makeService()]
) -> Destination {
    
    .services(services)
}

func makeSingleDestinationUtilityFlow(
    _ destination: Destination? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> UtilityFlow {
    
    let flow = UtilityFlow.init(stack: .init([
        destination ?? makeServicesDestination()
    ]))
    
    XCTAssertNoDiff(flow.stack.count, 1)
    
    return flow
}

func makeUtilityFlowState(
    _ flow: UtilityFlow
) -> PaymentsTransfersFlowState<Destination> {
    
    .init(route: .utilityFlow(flow))
}

func makeUtilityFlowState(
    _ destinations: Destination...
) -> PaymentsTransfersFlowState<Destination> {
    
    .init(route: .utilityFlow(.init(stack: .init(destinations))))
}

func makeFlow(
    _ destinations: Destination...
) -> Flow<Destination> {
    
    .init(stack: .init(destinations))
}

func makePPOStub(
    lastPaymentsCount: Int = 0,
    operatorsCount: Int = 1,
    searchText: String = "",
    isInflight: Bool = false,
    ppoEffect: PPOEffect? = nil
) -> (PPOState, PPOEffect?) {
    
    let ppoState = makePrePaymentOptionsState(
        lastPaymentsCount: lastPaymentsCount,
        operatorsCount: operatorsCount,
        searchText: searchText,
        isInflight: isInflight
    )
    
    return (ppoState, ppoEffect)
}

func makePrePaymentOptionsState(
    lastPaymentsCount: Int = 0,
    operatorsCount: Int = 1,
    searchText: String = "",
    isInflight: Bool = false
) -> PrepaymentOptionsState<LastPayment, Operator> {
    
    .init(
        lastPayments: (0..<lastPaymentsCount).map { _ in makeLastPayment() },
        operators: (0..<operatorsCount).map { _ in makeOperator() },
        searchText: searchText,
        isInflight: isInflight
    )
}
