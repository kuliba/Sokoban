//
//  InputStateWrapperViewFactory.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 23.05.2024.
//

import InputComponent

struct InputStateWrapperViewFactory<InputView> {
    
    let makeInputView: MakeInputView
}

extension InputStateWrapperViewFactory {
    
    typealias State = InputState<String>
    typealias Event = InputEvent
    typealias MakeInputView = (State, @escaping (Event) -> Void) -> InputView
}
