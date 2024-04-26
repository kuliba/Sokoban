//
//  InputPhoneReducer.swift
//
//
//  Created by Дмитрий Савушкин on 25.04.2024.
//

import Foundation

final class InputPhoneReducer {}

extension InputPhoneReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        switch event {
        case let .edit(text):
            return .entered(text)
            
        }
    }
}

extension InputPhoneReducer {
    
    typealias State = InputPhoneState
    typealias Event = InputPhoneEvent
}
