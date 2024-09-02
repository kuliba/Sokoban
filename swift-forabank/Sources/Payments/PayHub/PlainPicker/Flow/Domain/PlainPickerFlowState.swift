//
//  PlainPickerFlowState.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

public struct PlainPickerFlowState<Navigation> {
    
    public var navigation: Navigation?
    
    public init(
        navigation: Navigation? = nil
    ) {
        self.navigation = navigation
    }
}

extension PlainPickerFlowState: Equatable where Navigation: Equatable {}
