//
//  UserAccountNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.02.2024.
//

import FastPaymentsSettings
import UserAccountNavigationComponent

struct UserAccountNavigationStateManager {
    
    let reduce: Reduce
    let handleEffect: HandleEffect
}

extension UserAccountNavigationStateManager {
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    
    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
    
    typealias State = UserAccountRoute
    typealias Effect = UserAccountEffect
    typealias Event = UserAccountEvent
}
