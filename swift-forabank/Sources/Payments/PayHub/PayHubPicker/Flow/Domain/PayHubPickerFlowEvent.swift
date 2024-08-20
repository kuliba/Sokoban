//
//  PayHubPickerFlowEvent.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum PayHubPickerFlowEvent<Exchange, Latest, LatestFlow, Status, Templates> {
    
    case flowEvent(FlowEvent<Status>)
    case select(PayHubPickerItem<Latest>?)
    case selected(PayHubPickerFlowItem<Exchange, LatestFlow, Templates>?)
}

extension PayHubPickerFlowEvent: Equatable where Exchange: Equatable, Latest: Equatable, LatestFlow: Equatable, Status: Equatable, Templates: Equatable {}
