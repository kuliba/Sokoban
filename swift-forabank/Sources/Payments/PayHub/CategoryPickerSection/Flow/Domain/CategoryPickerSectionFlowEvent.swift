//
//  CategoryPickerSectionFlowEvent.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public enum CategoryPickerSectionFlowEvent<Category, CategoryModel, CategoryList> {
    
    case dismiss
    case receive(Receive)
    case select(Select)
}

public extension CategoryPickerSectionFlowEvent {
    
    enum Receive {
        
        case category(CategoryModel)
        case list(CategoryList)
    }
    
    enum Select {
        
        case category(Category)
        case list
    }
}

extension CategoryPickerSectionFlowEvent: Equatable where Category: Equatable, CategoryModel: Equatable, CategoryList: Equatable {}
extension CategoryPickerSectionFlowEvent.Receive: Equatable where CategoryModel: Equatable, CategoryList: Equatable {}
extension CategoryPickerSectionFlowEvent.Select: Equatable where Category: Equatable, CategoryList: Equatable {}
