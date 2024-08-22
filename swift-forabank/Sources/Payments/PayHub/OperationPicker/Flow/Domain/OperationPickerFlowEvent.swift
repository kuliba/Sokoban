//
//  OperationPickerFlowEvent.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum OperationPickerFlowEvent<Exchange, Latest, LatestFlow, Status, Templates> {
    
    case flowEvent(FlowEvent<Status>)
    case select(OperationPickerItem<Latest>?)
    case selected(OperationPickerFlowItem<Exchange, LatestFlow, Templates>?)
}

extension OperationPickerFlowEvent: Equatable where Exchange: Equatable, Latest: Equatable, LatestFlow: Equatable, Status: Equatable, Templates: Equatable {}
