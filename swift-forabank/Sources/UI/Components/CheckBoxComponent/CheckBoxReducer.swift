//
//  CheckBoxReducer.swift
//
//
//  Created by Дмитрий Савушкин on 26.04.2024.
//

import Foundation

final class CheckBoxReducer {}

extension CheckBoxReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        switch event {
        case .buttonTapped:
            return (
                !state,
                nil
            )
        }
    }
}

extension CheckBoxReducer {
    
    typealias State = Bool
    typealias Event = CheckBoxEvent
    typealias Effect = Never
}
