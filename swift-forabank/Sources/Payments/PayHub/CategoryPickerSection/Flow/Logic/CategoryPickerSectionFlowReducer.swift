//
//  CategoryPickerSectionFlowReducer.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public final class CategoryPickerSectionFlowReducer<Category, CategoryModel, CategoryList> {
    
    public init() {}
}

public extension CategoryPickerSectionFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .dismiss:
            state.destination = nil
            
        case let .receive(receive):
            switch receive {
            case let .category(category):
                state.destination = .category(category)
                
            case let .list(list):
                state.destination = .list(list)
            }
            
        case let .select(select):
            state.destination = nil

            switch select {                
            case let .category(category):
                effect = .showCategory(category)
                
            case let .list(categories):
                effect = .showAll(categories)
            }
        }
        
        return (state, effect)
    }
}

public extension CategoryPickerSectionFlowReducer {
    
    typealias State = CategoryPickerSectionFlowState<CategoryModel, CategoryList>
    typealias Event = CategoryPickerSectionFlowEvent<Category, CategoryModel, CategoryList>
    typealias Effect = CategoryPickerSectionFlowEffect<Category>
}
