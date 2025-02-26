//
//  RootViewModelFactory+makeUINInputViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 15.02.2025.
//

import Foundation
import TextFieldComponent
import InputComponent

extension RootViewModelFactory {
    
    func makeUINInputViewModel(
        value: String,
        placeholderText: String = "УИН",
        hintText: String? = nil,
        warningText: String = "От 20 до 25 знаков"
    ) -> RxInputViewModel {
        
        let textFieldReducer = TransformingReducer(
            placeholderText: placeholderText
        )
        
        let textInputValidator = TextInputValidator(
            hintText: hintText,
            warningText: warningText,
            validate: { 20...25 ~= $0.count }
        )
        
        let initialState = TextInputState(
            textField: .noFocus(value),
            message: textInputValidator.validate(.noFocus(value))
        )
        
        let reducer = TextInputReducer(
            textFieldReduce: textFieldReducer.reduce(_:_:),
            validate: textInputValidator.validate
        )
        
        let effectHandler = TextInputEffectHandler()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: schedulers.main
        )
    }
}

private extension TextFieldModel.Reducer {
    
    func reduce(
        _ state: TextFieldState,
        _ action: TextFieldAction
    ) -> TextFieldState {
        
        (try? reduce(state, with: action)) ?? state
    }
}
