//
//  ErrorWithRetry.swift
//  
//
//  Created by Igor Malyarov on 22.08.2023.
//

public struct ErrorWithRetry: Error {
    
    let error: Error
    let canRetry: Bool
    
    public init(error: Error, canRetry: Bool) {
        
        self.error = error
        self.canRetry = canRetry
    }
}
