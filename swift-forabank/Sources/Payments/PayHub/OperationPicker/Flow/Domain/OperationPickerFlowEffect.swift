//
//  OperationPickerFlowEffect.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum OperationPickerFlowEffect<Latest> {
    
    case select(OperationPickerItem<Latest>?)
}

public extension OperationPickerFlowEffect {
    
    enum Select: Equatable {}
}

extension OperationPickerFlowEffect: Equatable where Latest: Equatable {}
