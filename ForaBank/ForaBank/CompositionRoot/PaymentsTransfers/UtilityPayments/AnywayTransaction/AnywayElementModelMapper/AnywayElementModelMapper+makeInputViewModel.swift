//
//  AnywayElementModelMapper+makeInputViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.08.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import InputComponent
import TextFieldComponent
import TextFieldModel
import RxViewModel

extension AnywayElementModelMapper {
    
    func makeInputViewModel(
        with parameter: AnywayElement.Parameter,
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> ObservingInputViewModel {
        
        let placeholderText = "Введите значение"
        
        let initialState = TextInputState(
            parameter: parameter,
            placeholderText: placeholderText
        )
        let textFieldReducer = parameter.textFieldReducer(placeholderText: placeholderText)
        let validator = AnywayPaymentParameterValidator()
        let textInputValidator = TextInputValidator(
            hintText: parameter.uiAttributes.subTitle,
            warningText: parameter.uiAttributes.subTitle,
            validate: { validator.isValid($0, with: parameter.validation) }
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
            observe: {
            
                if let value = $0.textField.text {
                    
                    event(.setValue(value, for: parameter.uiComponent.id))
                }
            }
        )
    }
}

private extension TextInputState {
    
    init(
        parameter: AnywayElement.Parameter,
        placeholderText: String
    ) {
        switch parameter.field.value {
        case .none:
            self.init(textField: .placeholder(placeholderText))
            
        case let .some(value):
            self.init(textField: .noFocus(value))
        }
    }
}

private extension AnywayElement.Parameter {
    
    func textFieldReducer(
        placeholderText: String
    ) -> TransformingReducer {
        
        guard case .number = uiAttributes.dataType
        else { return .init(placeholderText: placeholderText) }
        
        return .sberNumericReducer(
            placeholderText: placeholderText
        )
    }
}

private extension TextFieldModel.Reducer {
    
    func reduce(
        _ state: TextFieldState,
        _ action: TextFieldAction
    ) -> TextFieldState {
        
        do {
            return try reduce(state, with: action)
        } catch {
            return state
        }
    }
}
