//
//  Transform+DSL.swift
//  
//
//  Created by Igor Malyarov on 22.05.2023.
//

import Foundation
import TextFieldDomain

// MARK: - DSL

extension Transform {
    
    // MARK: apply multiple actions
    
    func reduce(
        _ state: TextState,
        with actions: ((TextState) throws -> TextState)...
    ) throws -> [TextState] {
        
        var state = state
        var result = [state]
        
        for action in actions {
            
            state = transform(try action(state))
            result.append(state)
        }
        
        return result
    }
}
