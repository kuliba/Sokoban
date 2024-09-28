//
//  CategoryPickerSectionFlowReducer.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public final class CategoryPickerSectionFlowReducer<Category, SelectedCategory, CategoryList, Failure: Error> {
    
    public init() {}
}

public extension CategoryPickerSectionFlowReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.isLoading = false
        
        switch event {
        case .dismiss:
            state.navigation = nil
            
        case let .receive(receive):
            switch receive {
            case let .category(.failure(failure)):
                state.navigation = .failure(failure)
                
            case let .category(.success(category)):
                state.navigation = .destination( .category(category))
                
            case let .list(list):
                state.navigation = .destination(.list(list))
            }
            
        case let .select(select):
            state.isLoading = true
            state.navigation = nil

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
    
    typealias State = CategoryPickerSectionFlowState<SelectedCategory, CategoryList, Failure>
    typealias Event = CategoryPickerSectionFlowEvent<Category, SelectedCategory, CategoryList, Failure>
    typealias Effect = CategoryPickerSectionFlowEffect<Category>
}
