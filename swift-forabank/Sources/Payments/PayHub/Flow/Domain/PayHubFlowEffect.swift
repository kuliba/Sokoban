//
//  PayHubFlowEffect.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum PayHubFlowEffect<Latest> {
    
    case select(PayHubItem<Latest>?)
}

public extension PayHubFlowEffect {
    
    enum Select: Equatable {}
}

extension PayHubFlowEffect: Equatable where Latest: Equatable {}
