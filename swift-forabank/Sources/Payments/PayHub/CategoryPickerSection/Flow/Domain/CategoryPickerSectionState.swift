//
//  CategoryPickerSectionState.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public struct CategoryPickerSectionFlowState<Navigation> {
    
    public var isLoading: Bool
    public var navigation: Navigation?
    
    public init(
        isLoading: Bool = false,
        navigation: Navigation? = nil
    ) {
        self.isLoading = false
        self.navigation = navigation
    }
}

extension CategoryPickerSectionFlowState: Equatable where Navigation: Equatable {}
