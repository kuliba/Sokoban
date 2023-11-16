//
//  Retry.swift
//  
//
//  Created by Igor Malyarov on 07.08.2023.
//

public func retry<T>(
    attempts retryAttempts: Int = 1,
    action: () throws -> T
) rethrows -> T {
    
    do {
        return try action()
    } catch {
        guard retryAttempts > 0 else { throw error }
        
        return try retry(attempts: retryAttempts - 1, action: action)
    }
}
