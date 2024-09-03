//
//  CategoryPickerSectionState.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public struct CategoryPickerSectionFlowState<SelectedCategory, CategoryList> {
    
    public var destination: Destination?
    
    public init(
        destination: Destination? = nil
    ) {
        self.destination = destination
    }
}

public extension CategoryPickerSectionFlowState {
    
    typealias Destination = CategoryPickerSectionDestination<SelectedCategory, CategoryList>
}

extension CategoryPickerSectionFlowState: Equatable where SelectedCategory: Equatable, CategoryList: Equatable {}
