//
//  BlacklistFilter.swift
//
//
//  Created by Igor Malyarov on 24.06.2024.
//

import Foundation

/// A filter that checks whether requests should be blacklisted based on the number of attempts.
public final class BlacklistFilter<Request: Hashable> {
    
    private var attempts: [Request: Int] = [:]
    private let queue = DispatchQueue(label: "blacklistFilterQueue")
    private let isBlacklisted: IsBlacklisted
    
    /// Initialises a new instance of `BlacklistFilter`.
    ///
    /// - Parameter isBlacklisted: A closure that determines whether a request should be blacklisted based on the request and the number of attempts.
    public init(
        isBlacklisted: @escaping IsBlacklisted
    ) {
        self.isBlacklisted = isBlacklisted
    }
    
    public typealias IsBlacklisted = (Request, Int) -> Bool
}

public extension BlacklistFilter {
    
    /// Checks whether the given request is blacklisted.
    ///
    /// - Parameter request: The request to be checked.
    /// - Returns: A boolean indicating whether the request is blacklisted.
    func isBlacklisted(_ request: Request) -> Bool {
        
        queue.sync {
            
            attempts[request, default: 0] += 1
            let attemptCount = attempts[request] ?? 0
            
            return isBlacklisted(request, attemptCount)
        }
    }
}
