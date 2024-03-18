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

func makeEmptyUtilityFlow(
    file: StaticString = #file,
    line: UInt = #line
) -> UtilityFlow {
    
    let flow = UtilityFlow.init(stack: .init([]))
    
    XCTAssert(flow.stack.isEmpty)
    
    return flow
}

func makeDestination(
    lastPayments: [LastPayment] = [],
    operators: [Operator] = [],
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

func makeFlow(
    _ destinations: Destination...
) -> Flow<Destination> {
    
    .init(stack: .init(destinations))
}
