//
//  NameViewModel.swift
//
//
//  Created by Дмитрий Савушкин on 01.03.2024.
//

import Foundation

struct NameViewModel {
    
    var state: NameState
    
    init(state: NameState) {
        self.state = state
    }
    
    enum NameState {
        
        case collapse
        case expended
    }
}
