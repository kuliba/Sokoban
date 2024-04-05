//
//  ProductNavigationStateManager.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 04.04.2024.
//

import SwiftUI

struct ProductNavigationStateManager {
    
   // let bottomSheetReduce: Reduce
    let alertReduce: Reduce
   // let handleEffect: HandleEffect
}

extension ProductNavigationStateManager {
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    
    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
    
    typealias State = Alert.ViewModel?
    typealias Effect = Never
    typealias Event = AlertEvent
}

enum AlertEvent {
    
    case showBlockAlert
    case showAdditionalOtherAlert
    case closeAlert
}


extension ProductNavigationStateManager {
    
    static let preview: Self = .init(alertReduce: AlertReducer(productAlertsViewModel: .default).reduce)
}
