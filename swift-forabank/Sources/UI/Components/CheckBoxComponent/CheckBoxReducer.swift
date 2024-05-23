//
//  CheckBoxReducer.swift
//
//
//  Created by Дмитрий Савушкин on 26.04.2024.
//

import Foundation

final class CheckBoxReducer<Icon> {}

extension CheckBoxReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        switch event {
        case .buttonTapped:
            return (
                .init(isChecked: !state.isChecked),
                nil
            )
        }
    }
}

extension CheckBoxReducer {
    
    typealias State = CheckBoxState
    typealias Event = CheckBoxEvent
    typealias Effect = Never
}
