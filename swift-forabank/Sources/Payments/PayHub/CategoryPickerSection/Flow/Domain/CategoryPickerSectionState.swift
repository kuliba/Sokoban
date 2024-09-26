//
//  CategoryPickerSectionState.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public struct CategoryPickerSectionFlowState<SelectedCategory, CategoryList, Failure> {
    
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

public extension CategoryPickerSectionFlowState {
    
    enum Navigation {
        
        case destination(Destination)
        case failure(Failure)
    }
    
    typealias Destination = CategoryPickerSectionDestination<SelectedCategory, CategoryList>
}

extension CategoryPickerSectionFlowState: Equatable where SelectedCategory: Equatable, CategoryList: Equatable, Failure: Equatable {}
extension CategoryPickerSectionFlowState.Navigation: Equatable where SelectedCategory: Equatable, CategoryList: Equatable, Failure: Equatable {}
