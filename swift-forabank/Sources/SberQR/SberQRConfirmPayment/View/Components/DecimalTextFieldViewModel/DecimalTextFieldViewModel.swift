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
        locale: Locale = .current,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> DecimalTextFieldViewModel {
        
        let reducer = ChangingReducer.decimal(
            currencySymbol: currencySymbol,
            locale: locale
        )
        
        return .init(
            initialState: .noFocus("0 \(currencySymbol)"),
            reducer: reducer,
            keyboardType: .decimal,
            scheduler: scheduler
        )
    }
}
