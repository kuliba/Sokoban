//
//  CategoryPickerSectionState.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public struct CategoryPickerSectionFlowState<CategoryModel, CategoryList> {
    
    public var destination: Destination?
    
    public init(
        destination: Destination? = nil
    ) {
        self.destination = destination
    }
}

public extension CategoryPickerSectionFlowState {
    
    enum Destination {
        
        case category(CategoryModel)
        case list(CategoryList)
    }
}

extension CategoryPickerSectionFlowState: Equatable where CategoryModel: Equatable, CategoryList: Equatable {}
extension CategoryPickerSectionFlowState.Destination: Equatable where CategoryModel: Equatable, CategoryList: Equatable {}
