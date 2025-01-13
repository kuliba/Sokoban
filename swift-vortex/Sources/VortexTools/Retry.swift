//
//  Retry.swift
//
//
//  Created by Nikolay Pochekuev on 12.11.2024.
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
