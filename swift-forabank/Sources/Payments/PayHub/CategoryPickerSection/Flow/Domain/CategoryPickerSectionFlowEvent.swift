//
//  CategoryPickerSectionFlowEvent.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public enum CategoryPickerSectionFlowEvent<Category, SelectedCategory, CategoryList> {
    
    case dismiss
    case receive(Receive)
    case select(Select)
}

public extension CategoryPickerSectionFlowEvent {
    
    enum Receive {
        
        case category(SelectedCategory)
        case list(CategoryList)
    }
    
    enum Select {
        
        case category(Category)
        case list([Category])
    }
}

extension CategoryPickerSectionFlowEvent: Equatable where Category: Equatable, SelectedCategory: Equatable, CategoryList: Equatable {}
extension CategoryPickerSectionFlowEvent.Receive: Equatable where SelectedCategory: Equatable, CategoryList: Equatable {}
extension CategoryPickerSectionFlowEvent.Select: Equatable where Category: Equatable, CategoryList: Equatable {}
