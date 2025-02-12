//
//  InputViewModel.swift
//  C2GPreviewApp
//
//  Created by Igor Malyarov on 12.02.2025.
//

import FlowCore
import PaymentComponents
import RxViewModel
import TextFieldComponent

typealias RxInputViewModel = RxViewModel<TextInputState, TextInputEvent, TextInputEffect>

func makeInputViewModel(
) -> RxInputViewModel {
    
    return .init(
        initialState: initialState,
        reduce: reducer.reduce(_:_:),
        handleEffect: effectHandler.handleEffect(_:_:)
    )
}

func makeInputViewModel(
) -> Node<RxInputViewModel> {
    
    let model = makeInputViewModel()
    let cancellable = model.$state
        .compactMap(\.textField.text)
        .debounce(for: 0.1, scheduler: DispatchQueue.main)
        .removeDuplicates()
        .sink { event(.setValue($0, for: parameter.uiComponent.id)) }
    
    return .init()
}
