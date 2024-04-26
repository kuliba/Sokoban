//
//  InputReducer.swift
//
//
//  Created by Дмитрий Савушкин on 25.04.2024.
//

import Foundation

final class InputReducer<Icon> {}

extension InputReducer {
    
    func reduce(
        _ state: State<Icon>,
        _ event: Event
    ) -> State<Icon> {
        
        switch event {
        case let .edit(text):
            return .init(
                dynamic: .init(value: text),
                settings: state.settings
            )
        }
    }
}

extension InputReducer {
    
    typealias State = InputState
    typealias Event = InputEvent
}
