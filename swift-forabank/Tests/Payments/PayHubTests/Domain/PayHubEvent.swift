//
//  PayHubEvent.swift
//  
//
//  Created by Igor Malyarov on 15.08.2024.
//

enum PayHubEvent<Exchange, Latest, Status, Templates> {
    
    case flowEvent(FlowEvent<Status>)
    case loaded([PayHubItem<Exchange, Latest, Templates>])
}

extension PayHubEvent: Equatable where Exchange: Equatable, Latest: Equatable, Status: Equatable, Templates: Equatable {}
