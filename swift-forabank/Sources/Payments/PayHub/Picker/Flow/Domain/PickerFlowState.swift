//
//  PickerFlowState.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public struct PickerFlowState<Navigation> {
    
    public var isLoading: Bool
    public var navigation: Navigation?
    
    public init(
        isLoading: Bool = false,
        navigation: Navigation? = nil
    ) {
        self.isLoading = isLoading
        self.navigation = navigation
    }
}

extension PickerFlowState: Equatable where Navigation: Equatable {}
