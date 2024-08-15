//
//  PayHubEvent.swift
//  
//
//  Created by Igor Malyarov on 15.08.2024.
//

enum PayHubEvent<ExchangeFlow, Latest, Status, TemplatesFlow> {
    
    case flowEvent(FlowEvent<Status>)
    case loaded([PayHubItem<ExchangeFlow, Latest, TemplatesFlow>])
}

extension PayHubEvent: Equatable where ExchangeFlow: Equatable, Latest: Equatable, Status: Equatable, TemplatesFlow: Equatable {}
