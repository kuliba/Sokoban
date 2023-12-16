//
//  DecimalTextFieldViewModel.swift
//
//
//  Created by Igor Malyarov on 14.12.2023.
//

import Foundation
import TextFieldComponent

public typealias DecimalTextFieldViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>

public extension DecimalTextFieldViewModel {
    
    static func decimal(
        currencySymbol: String = "₽",
        locale: Locale = .autoupdatingCurrent,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> DecimalTextFieldViewModel {
        
        let reducer = ChangingReducer.decimal(
            currencySymbol: currencySymbol,
            locale: locale
        )
        let initialState = reducer.setToZero()
        
        return .init(
            initialState: initialState,
            reducer: reducer,
            keyboardType: .decimal,
            scheduler: scheduler
        )
    }
}

private extension ChangingReducer {
    
    func setToZero() -> TextFieldState {
        
        do {
            let started = try reduce(
                .placeholder(""),
                with: .startEditing
            )
            let zero = try reduce(
                started,
                with: .changeText("0", in: .zero)
            )
            
            return try reduce(
                zero,
                with: .finishEditing
            )
        } catch {
            
            return .placeholder("")
        }
    }
}
