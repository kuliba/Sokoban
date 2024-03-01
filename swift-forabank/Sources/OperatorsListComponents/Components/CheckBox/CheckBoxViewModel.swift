//
//  CheckBoxViewModel.swift
//  
//
//  Created by Дмитрий Савушкин on 01.03.2024.
//

import Foundation

struct CheckBoxViewModel {
    
    let state: State
    let title: String
    let tapAction: () -> Void
    
    internal init(
        state: CheckBoxViewModel.State,
        title: String,
        tapAction: @escaping () -> Void
    ) {
        self.state = state
        self.title = title
        self.tapAction = tapAction
    }
    
    enum State {
        
        case checked
        case unchecked
    }
}
