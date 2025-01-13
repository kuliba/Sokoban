//
//  Model+performOrWaitForActive.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.10.2024.
//

import Combine
import CombineSchedulers
import VortexTools
import Foundation

extension Model {
    
    /// Runs the provided work closure once the session is authorised.
    /// - Parameters:
    ///   - work: The closure to be executed when authorisation is confirmed.
    /// - Returns: An `AnyCancellable` that manages the subscription until the work is performed.
    /// - Note: If the session is already authorised, the work will be executed immediately. Otherwise, it will subscribe to changes in authorisation status.
    func performOrWaitForActive(
        _ work: @escaping () -> Void
    ) -> AnyCancellable {
        
        if let token {
            return Just(token)
                .sink { _ in work() }
        } else {
            return sessionAgent.sessionState.map(\.token)
                .runOnceOnNonNilValue(work)
        }
    }
}

extension SessionState {
    
    var token: String? {
        
        guard case let .active(_, credentials) = self
        else { return nil }
        
        return credentials.token
    }
}
