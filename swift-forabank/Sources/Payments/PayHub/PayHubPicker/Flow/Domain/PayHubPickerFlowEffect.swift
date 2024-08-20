//
//  PayHubPickerFlowEffect.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum PayHubPickerFlowEffect<Latest> {
    
    case select(PayHubPickerItem<Latest>?)
}

public extension PayHubPickerFlowEffect {
    
    enum Select: Equatable {}
}

extension PayHubPickerFlowEffect: Equatable where Latest: Equatable {}
