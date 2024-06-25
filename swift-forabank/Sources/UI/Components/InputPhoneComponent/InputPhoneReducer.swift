//
//  InputPhoneReducer.swift
//
//
//  Created by Дмитрий Савушкин on 25.04.2024.
//

import Foundation

public final class InputPhoneReducer {
    
    public init() {}
}

extension InputPhoneReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        switch event {
        case let .edit(text):
            return (.entered(text), nil)
        }
    }
}

extension InputPhoneReducer {
    
    typealias State = InputPhoneState
    typealias Event = InputPhoneEvent
    typealias Effect = Never
}
