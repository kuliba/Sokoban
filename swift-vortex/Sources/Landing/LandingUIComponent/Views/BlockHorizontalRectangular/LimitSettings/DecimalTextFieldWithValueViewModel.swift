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
import SwiftUI

typealias DecimalTextFieldWithValueViewModel = ReducerTextFieldViewModel<ToolbarViewModel, KeyboardType>

extension DecimalTextFieldWithValueViewModel {
    
    typealias GetDecimal = (TextFieldState) -> Decimal
    
    static func decimal(
        formatter: DecimalFormatter,
        maxValue: Decimal,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) -> DecimalTextFieldWithValueViewModel {
        
        let reducer = ChangingReducer.decimal(
            formatter: formatter,
            maxValue: 999999999.99
        )
        
        let initialState = maxValue >= .maxLimit ? .noFocus(.noLimits) : reducer.setToValue(maxValue)
        
        return .init(
            initialState: initialState,
            reducer: reducer,
            keyboardType: .decimal,
            scheduler: scheduler
        )
    }
    
    func textFieldColor(
        first: Color,
        second: Color
    ) -> Color {
        
        guard let text = state.text else { return first }
        
        let decimalCharacters = CharacterSet.decimalDigits

        let decimalRange = text.rangeOfCharacter(from: decimalCharacters)
        
        return (decimalRange != nil) ? first : second
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

extension Decimal {
    
    static let maxLimit: Self = 999999999
}

extension String {
    
    static let noLimits: Self = "Без ограничений"
}
