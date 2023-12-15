//
//  DecimalTextFieldViewModel.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import TextFieldComponent

public typealias DecimalTextFieldViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>

public extension DecimalTextFieldViewModel {
    
    static func decimal(
        currencySymbol: String = "₽",
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> DecimalTextFieldViewModel {
        
        let reducer = ChangingReducer.decimal(
            currencySymbol: currencySymbol
        )
        
        return .init(
            initialState: .noFocus("0 \(currencySymbol)"),
            reducer: reducer,
            keyboardType: .decimal,
            scheduler: scheduler
        )
    }
}
