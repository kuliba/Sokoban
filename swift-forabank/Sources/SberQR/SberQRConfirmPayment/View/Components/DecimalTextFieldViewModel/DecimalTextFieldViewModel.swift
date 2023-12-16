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
    
    typealias GetDecimal = (TextFieldState) -> Decimal
    
    static func decimal(
        currencySymbol: String,
        locale: Locale = .autoupdatingCurrent,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> (DecimalTextFieldViewModel, GetDecimal) {
        
        let formatter = DecimalFormatter(
            currencySymbol: currencySymbol,
            locale: locale
        )
        let reducer = ChangingReducer.decimal(
            formatter: formatter
        )
        let initialState = reducer.setToZero()
        
        let textField = DecimalTextFieldViewModel(
            initialState: initialState,
            reducer: reducer,
            keyboardType: .decimal,
            scheduler: scheduler
        )
        
        return (textField, formatter.getDecimal)
    }
}

private extension DecimalFormatter {
    
    func getDecimal(_ textFieldState: TextFieldState) -> Decimal {
        
        switch textFieldState {
        
        case .placeholder:
            return 0

        case let .noFocus(text):
            return number(from: text)
            
        case let .editing(textState):
            return number(from: textState.text)
        }
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
