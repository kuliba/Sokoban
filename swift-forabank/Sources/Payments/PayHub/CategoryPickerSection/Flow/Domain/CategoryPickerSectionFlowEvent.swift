//
//  CategoryPickerSectionFlowEvent.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public enum CategoryPickerSectionFlowEvent<Category, SelectedCategory, CategoryList, Failure: Error> {
    
    case dismiss
    case receive(Receive)
    case select(Select)
}

public extension CategoryPickerSectionFlowEvent {
    
    enum Receive {
        
        case category(Result<SelectedCategory, Failure>)
        case list(CategoryList)
    }
    
    enum Select {
        
        case category(Category)
        case list([Category])
    }
}

extension CategoryPickerSectionFlowEvent: Equatable where Category: Equatable, SelectedCategory: Equatable, CategoryList: Equatable, Failure: Equatable {}
extension CategoryPickerSectionFlowEvent.Receive: Equatable where SelectedCategory: Equatable, CategoryList: Equatable, Failure: Equatable {}
extension CategoryPickerSectionFlowEvent.Select: Equatable where Category: Equatable, CategoryList: Equatable, Failure: Equatable {}
