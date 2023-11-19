//
//  ErrorWithRetryAttempts.swift
//  
//
//  Created by Igor Malyarov on 21.08.2023.
//

public struct ErrorWithRetryAttempts: Error {
    
    let error: Error
    let retryAttempts: Int
    
    public init(error: Error, retryAttempts: Int) {
        
        self.error = error
        self.retryAttempts = retryAttempts
    }
}
