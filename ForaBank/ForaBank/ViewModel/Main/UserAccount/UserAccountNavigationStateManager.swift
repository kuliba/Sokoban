//
//  UserAccountNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.02.2024.
//

import FastPaymentsSettings
import UserAccountNavigationComponent

struct UserAccountNavigationStateManager {
    
    let userAccountReduce: UserAccountReduce
    let userAccountHandleEffect: UserAccountHandleEffect
}

extension UserAccountNavigationStateManager {
    
    typealias UserAccountReduce = (UserAccountRoute, UserAccountEvent) -> (UserAccountRoute, UserAccountEffect?)
    
    typealias Dispatch = (UserAccountEvent) -> Void
    typealias UserAccountHandleEffect = (UserAccountEffect, @escaping Dispatch) -> Void
}
