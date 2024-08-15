//
//  PayHubFlowEvent.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum PayHubFlowEvent<Exchange, Latest, LatestFlow, Status, Templates> {
    
    case flowEvent(FlowEvent<Status>)
    case select(PayHubItem<Latest>?)
    case selected(PayHubFlowItem<Exchange, LatestFlow, Templates>?)
}

extension PayHubFlowEvent: Equatable where Exchange: Equatable, Latest: Equatable, LatestFlow: Equatable, Status: Equatable, Templates: Equatable {}
