//
//  CreateDraftCollateralLoanApplicationDomain+Reducer.swift
//  
//
//  Created by Valentin Ozerov on 16.01.2025.
//

import InputComponent
import TextFieldDomain

extension CreateDraftCollateralLoanApplicationDomain {
    
    public final class Reducer {
        
        public init() {}
        
        public func reduce(_ state: State, _ event: Event) -> (State, Effect?) {
            
            var state = state
            var effect: Effect?
            
            switch event {
            case .selectedAmount(_):
                break
                
            case .selectedPeriod(_):
                break
                
            case .selectedCity(_):
                break
                
            case .tappedContinue:
                state.isLoading = true
                effect = .createDraftApplication(state.createDraftApplicationPayload)
                
            case let .applicationCreated(result):
                state.applicationId = try? result.get().applicationId
                state.stage = .confirm
                state.isLoading = false
                
            case .tappedSubmit:
                state.isLoading = true
                effect = .saveConsents(state.saveConsentspayload)
                
            case .tappedBack:
                if state.stage == .confirm {
                    
                    state.stage = .correctParameters
                }
                
            case let .showSaveConsentsResult(result):
                state.isLoading = false
                state.saveConsentsResult = result
                
            case let .inputComponentEvent(inputComponentEvent):
                switch inputComponentEvent {
                case let .textField(textFieldAction):
//                    let textField = textFieldReduce(state.textInputState.textField, textFieldAction)
//                    let message = validate(textField)
//                    state.textInputState.textField = textField
//                    state.textInputState.message = message
                    
                    switch textFieldAction {
                    case .startEditing:
                        break
                        
                    case .finishEditing:
                        break
                        
                    case .changeText:
                        break
                        
                    case .setTextTo(_):
                        break
                    }
                }
            }
            
            return (state, effect)
        }
        
        // MARK: Helpers
//        func makeTextFieldReduce() -> TextFieldReduce {
//            
//            TextInputReducer(
//                textFieldReduce: textFieldReducer.reduce(_:_:),
//                validate: textInputValidator.validate
//            )
//        }
        
//        func textFieldReducer(
//            placeholderText: String
//        ) -> TextFieldReduce {
//            
//            switch (., masking.composedMask) {
//            case (.number, .none):
//                return TransformingReducer.sberNumericReducer(
//                    placeholderText: pleaceholderText
//                )
//                
//            default:
//                return ChangingReducer.mask(
//                    placeholderText: placeholderText,
//                    pattern: masking.composedMask ?? ""
//                )
//            }
//        }
    }
    
    public typealias TextFieldReduce = (TextFieldState, TextFieldAction) -> TextFieldState
    public typealias Validate = (TextFieldState) -> TextInputState.Message?
}

//let textInputValidator = AnywayPaymentParameterValidator()
//let textInputValidator = TextInputValidator(
//    hintText: "subTitle",
//    warningText: "subTitle",
//    validate: { validator.isValid($0, with: parameter.validation) }
//)

