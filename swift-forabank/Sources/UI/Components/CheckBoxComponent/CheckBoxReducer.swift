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
        _ isChecked: Bool,
        _ event: Event
    ) -> Bool {
        
        switch event {
        case .buttonTapped:
            return !isChecked
        }
    }
}

extension CheckBoxReducer {
    
    typealias Event = CheckBoxEvent
}
