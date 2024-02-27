//
//  PaymentsTransfersNavigationStateManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

struct PaymentsTransfersNavigationStateManager {
    
    let reduce: Reduce
    let handleEffect: HandleEffect
}

extension PaymentsTransfersNavigationStateManager {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
}

extension PaymentsTransfersNavigationStateManager {

    typealias State = PaymentsTransfersViewModel.Route
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
}

enum PaymentsTransfersEvent {
    
    case latestPaymentTap(UtilitiesViewModel.LatestPayment)
    case operatorTap(UtilitiesViewModel.Operator)
}

enum PaymentsTransfersEffect {
    
}

// MARK: - Preview Content

extension PaymentsTransfersNavigationStateManager {
    
    static let preview: Self = .init(
        reduce: { state, _ in (state, nil) },
        handleEffect: { _,_ in }
    )
}
