//
//  NameViewState.swift
//
//
//  Created by Дмитрий Савушкин on 01.03.2024.
//

import Foundation

public struct NameViewState {
    
    let state: NameState
    
    public init(state: NameState) {
        self.state = state
    }
    
    public enum NameState {
        
        case collapse
        case expended
    }
}
