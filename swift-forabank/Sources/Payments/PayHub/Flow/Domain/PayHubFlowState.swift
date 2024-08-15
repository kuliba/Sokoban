//
//  PayHubFlowState.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public struct PayHubFlowState<Exchange, Latest, Status, Templates> {
    
    public var isLoading = false
    public var selected: Selected?
    public var status: Status?
    
    public init(
        isLoading: Bool = false,
        selected: Selected? = nil,
        status: Status? = nil
    ) {
        self.isLoading = isLoading
        self.selected = selected
        self.status = status
    }
    
    public typealias Selected = PayHubFlowItem<Exchange, Latest, Templates>
}

extension PayHubFlowState: Equatable where Exchange: Equatable, Latest: Equatable, Status: Equatable, Templates: Equatable {}
