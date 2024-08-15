//
//  PayHubEvent.swift
//  
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum PayHubEvent<Latest> {
    
    #warning("just [Latest]")
    case loaded([PayHubItem<Latest>])
}

extension PayHubEvent: Equatable where Latest: Equatable {}
