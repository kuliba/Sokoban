//
//  Reducer.swift
//  
//
//  Created by Igor Malyarov on 21.05.2023.
//

import TextFieldDomain

public protocol Reducer {
    
    func reduce(
        _ state: TextFieldState,
        with action: TextFieldAction
    ) throws -> TextFieldState
}
