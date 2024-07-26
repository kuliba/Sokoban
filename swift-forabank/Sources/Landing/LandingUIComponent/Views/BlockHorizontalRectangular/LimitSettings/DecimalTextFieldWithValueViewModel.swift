//
//  DecimalTextFieldWithValueViewModel.swift
//
//
//  Created by Andryusina Nataly on 23.07.2024.
//

import Foundation
import TextFieldDomain
import TextFieldUI
import TextFieldModel

typealias DecimalTextFieldWithValueViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>

extension DecimalTextFieldWithValueViewModel {
    
    typealias GetDecimal = (TextFieldState) -> Decimal
    
    static func decimal(
        formatter: DecimalFormatter,
        maxValue: Decimal,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> DecimalTextFieldWithValueViewModel {
        
        let reducer = ChangingReducer.decimal(
            formatter: formatter
        )
        let initialState = reducer.setToValue(maxValue)
        
        return .init(
            initialState: initialState,
            reducer: reducer,
            keyboardType: .decimal,
            scheduler: scheduler
        )
    }
}

private extension ChangingReducer {
    
    func setToValue(_ value: Decimal) -> TextFieldState {
        
        do {
            let started = try reduce(
                .placeholder(""),
                with: .startEditing
            )
            let value = try reduce(
                started,
                with: .changeText("\(value)".formattedValue("₽"), in: .zero)
            )
            
            return try reduce(
                value,
                with: .finishEditing
            )
        } catch {
            
            return .placeholder("")
        }
    }
}
