//
//  PayHubFlowEvent.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum PayHubFlowEvent<Exchange, Latest, Status, Templates> {
    
    case flowEvent(FlowEvent<Status>)
    case selected(PayHubFlowItem<Exchange, Latest, Templates>?)
}

extension PayHubFlowEvent: Equatable where Exchange: Equatable, Latest: Equatable, Status: Equatable, Templates: Equatable {}
