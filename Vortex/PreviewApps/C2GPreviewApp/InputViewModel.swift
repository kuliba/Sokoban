//
//  InputViewModel.swift
//  C2GPreviewApp
//
//  Created by Igor Malyarov on 12.02.2025.
//

import FlowCore
import Foundation
import PaymentComponents
import RxViewModel
import TextFieldComponent

typealias RxInputViewModel = RxViewModel<TextInputState, TextInputEvent, TextInputEffect>

extension RxInputViewModel {
    
    static func makeUINInputViewModel(
        placeholderText: String = "УИН",
        hintText: String = "",
        warningText: String = "От 20 до 25 знаков"
    ) -> RxInputViewModel {
        
        let textFieldReducer = TransformingReducer(
            placeholderText: placeholderText
        )
        
        let initialState = TextInputState(textField: .placeholder(placeholderText))
        
        let textInputValidator = TextInputValidator(
            hintText: hintText,
            warningText: warningText,
            validate: { $0.count == 20 || $0.count == 25 }
        )
        
        let reducer = TextInputReducer(
            textFieldReduce: textFieldReducer.reduce(_:_:),
            validate: textInputValidator.validate
        )
        
        let effectHandler = TextInputEffectHandler()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
    
    //static func makeInputViewNode(
    //) -> Node<RxInputViewModel> {
    //
    //    let model = makeInputViewModel()
    //    let cancellable = model.$state
    //        .compactMap(\.textField.text) // ????
    //    //    .debounce(for: 0.1, scheduler: DispatchQueue.main)
    //        .removeDuplicates()
    //        .sink { event(.setValue($0, for: parameter.uiComponent.id)) }
    //
    //    return .init(model: model, cancellable: cancellable)
    //}
}

private extension TextFieldModel.Reducer {
    
    func reduce(
        _ state: TextFieldState,
        _ action: TextFieldAction
    ) -> TextFieldState {
        
        (try? reduce(state, with: action)) ?? state
    }
}
