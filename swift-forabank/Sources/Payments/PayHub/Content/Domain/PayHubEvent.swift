//
//  PayHubEvent.swift
//  
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum PayHubEvent<Latest> {
    
    case load
    case loaded([Latest])
    case select(PayHubItem<Latest>?)
}

extension PayHubEvent: Equatable where Latest: Equatable {}
