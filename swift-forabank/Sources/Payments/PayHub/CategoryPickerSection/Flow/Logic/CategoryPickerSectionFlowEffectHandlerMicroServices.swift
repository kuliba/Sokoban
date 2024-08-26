//
//  CategoryPickerSectionFlowEffectHandlerMicroServices.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public struct CategoryPickerSectionFlowEffectHandlerMicroServices<Category, CategoryModel, CategoryList> {
    
    public let showAll: ShowAll
    public let showCategory: ShowCategory
    
    public init(
        showAll: @escaping ShowAll,
        showCategory: @escaping ShowCategory
    ) {
        self.showAll = showAll
        self.showCategory = showCategory
    }
}

public extension CategoryPickerSectionFlowEffectHandlerMicroServices {
    
    typealias ShowAll = (@escaping (CategoryList) -> Void) -> Void
    typealias ShowCategory = (Category, @escaping (CategoryModel) -> Void) -> Void
}
