//
//  CategoryPickerSectionFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public final class CategoryPickerSectionFlowEffectHandler<Category, SelectedCategory, CategoryList> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = CategoryPickerSectionFlowEffectHandlerMicroServices<Category, SelectedCategory, CategoryList>
}

public extension CategoryPickerSectionFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .showAll(categories):
            microServices.showAll(categories) { dispatch(.receive(.list($0))) }
            
        case let .showCategory(category):
            microServices.showCategory(category) { dispatch(.receive(.category($0))) }
        }
    }
}

public extension CategoryPickerSectionFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = CategoryPickerSectionFlowEvent<Category, SelectedCategory, CategoryList>
    typealias Effect = CategoryPickerSectionFlowEffect<Category>
}
