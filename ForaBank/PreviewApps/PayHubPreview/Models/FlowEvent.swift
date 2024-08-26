//
//  FlowEvent.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import PayHub

typealias FlowEvent = PayHub.FlowEvent<Status>

enum Status: Equatable {
    
    case main
}
