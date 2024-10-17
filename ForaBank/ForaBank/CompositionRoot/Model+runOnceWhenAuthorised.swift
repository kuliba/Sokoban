//
//  Model+runOnceWhenAuthorised.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.10.2024.
//

import Combine
import CombineSchedulers
import ForaTools
import Foundation

extension Model {
    
    /// Runs the provided work closure once the session is authorised.
    /// - Parameters:
    ///   - work: The closure to be executed when authorisation is confirmed.
    ///   - scheduler: The scheduler on which the work should be executed.
    /// - Returns: An `AnyCancellable` that manages the subscription until the work is performed.
    /// - Note: If the session is already authorised, the work will be executed immediately. Otherwise, it will subscribe to changes in authorisation status.
    func runOnceWhenAuthorised(
        _ work: @escaping () -> Void,
        on scheduler: AnySchedulerOf<DispatchQueue>
    ) -> AnyCancellable {
        
        if let token {
            return Just(token)
                .receive(on: scheduler)
                .sink { _ in work() }
        } else {
            return sessionAgent.sessionState.map(\.token)
                .receive(on: scheduler)
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
