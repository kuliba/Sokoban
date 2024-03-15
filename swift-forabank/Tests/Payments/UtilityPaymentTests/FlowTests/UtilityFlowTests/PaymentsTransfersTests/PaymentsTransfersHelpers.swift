//
//  PaymentsTransfersHelpers.swift
//
//
//  Created by Igor Malyarov on 15.03.2024.
//

import UtilityPayment
import XCTest

typealias UtilityFlow = Flow<Destination>
typealias Destination = UtilityDestination<LastPayment, Operator>

func makeEmptyUtilityFlow(
    file: StaticString = #file,
    line: UInt = #line
) -> UtilityFlow {
    
    let flow = UtilityFlow.init(stack: .init([]))
    
    XCTAssert(flow.stack.isEmpty)
    
    return flow
}

func makeSingleDestinationUtilityFlow(
    _ destination: Destination? = nil,
    file: StaticString = #file,
    line: UInt = #line
) -> UtilityFlow {
    
    let flow = UtilityFlow.init(stack: .init([
        destination ?? .services
    ]))
    
    XCTAssertNoDiff(flow.stack.count, 1)
    
    return flow
}

func makeUtilityFlowState(
    _ flow: UtilityFlow
) -> PaymentsTransfersState<Destination> {
    
    .init(route: .utilityFlow(flow))
}
