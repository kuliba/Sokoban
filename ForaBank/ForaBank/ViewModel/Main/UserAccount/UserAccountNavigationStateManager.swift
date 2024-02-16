//
//  UserAccountNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.02.2024.
//

import FastPaymentsSettings
import ManageSubscriptionsUI
import UserAccountNavigationComponent

struct UserAccountNavigationStateManager {
    
    let fastPaymentsFactory: FastPaymentsFactory
    let makeSubscriptionsViewModel: MakeSubscriptionsViewModel
    let reduce: Reduce
    let handleEffect: HandleEffect
}

extension UserAccountNavigationStateManager {

    typealias OnDelete = (SubscriptionViewModel.Token, String) -> Void
    typealias OnDetail = (SubscriptionViewModel.Token) -> Void
    typealias MakeSubscriptionsViewModel = (@escaping OnDelete, @escaping OnDetail) -> SubscriptionsViewModel
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    
    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
    
    typealias State = UserAccountRoute
    typealias Effect = UserAccountEffect
    typealias Event = UserAccountEvent
}
