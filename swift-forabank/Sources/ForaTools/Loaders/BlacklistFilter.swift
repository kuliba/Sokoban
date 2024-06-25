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
    /// The `isBlacklisted` closure determines whether a request should be blacklisted based on the request and the number of attempts.
    /// The closure can return:
    /// - `true`: if the request should be blacklisted.
    /// - `false`: if the request should not be blacklisted.
    /// - `nil`: if counting the attempt is deemed unnecessary or irrelevant.
    ///
    /// The `nil` return value is useful in scenarios where certain conditions mean that attempts should not be counted at all, such as temporary network issues or other non-critical failures.
    ///
    /// - Parameter isBlacklisted: A closure that determines whether a request should be blacklisted based on the request and the number of attempts.
    public init(
        isBlacklisted: @escaping IsBlacklisted
    ) {
        self.isBlacklisted = isBlacklisted
    }
    
    public typealias IsBlacklisted = (Request, Int) -> Bool?
}

public extension BlacklistFilter {
    
    /// Checks whether the given request is blacklisted.
    ///
    /// This method increments the attempt count for the request and uses the provided `isBlacklisted` closure to determine if the request should be blacklisted.
    ///
    /// - Parameter request: The request to be checked.
    /// - Returns: A boolean indicating whether the request is blacklisted.
    func isBlacklisted(_ request: Request) -> Bool {
        
        queue.sync {
            
            let attemptCount = attempts[request, default: 0] + 1
            
            if let isBlacklisted = isBlacklisted(request, attemptCount) {
                attempts[request] = attemptCount
                return isBlacklisted
            } else {
                return false
            }
        }
    }
}
