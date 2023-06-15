//
//  PickerWithPreviewModel.swift
//  
//
//  Created by Andryusina Nataly on 06.06.2023.
//

import Foundation

public final class PickerWithPreviewModel: ObservableObject {
        
    @Published public private(set) var state: ComponentState
    
    public init(
        state: ComponentState,
        options: [SubscriptionType: [OptionWithMapImage]]
    ) {
        self.state = state
        self.options = options
        self.reducer = SelectingReducer(options: options)
    }
    
    let options: [SubscriptionType: [OptionWithMapImage]]
    
    private let reducer: SelectingReducer
        
    func send(_ action: ComponentAction) {
        
        state = reducer.reduce(
            state,
            action: action
        )
    }
}
