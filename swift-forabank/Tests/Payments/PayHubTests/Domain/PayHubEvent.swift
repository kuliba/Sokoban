//
//  PayHubEvent.swift
//  
//
//  Created by Igor Malyarov on 15.08.2024.
//

enum PayHubEvent<Latest, Status, TemplatesFlow> {
    
    case flowEvent(FlowEvent<Status>)
    case loaded([PayHubItem<Latest, TemplatesFlow>])
}

extension PayHubEvent: Equatable where Latest: Equatable, Status: Equatable, TemplatesFlow: Equatable {}
