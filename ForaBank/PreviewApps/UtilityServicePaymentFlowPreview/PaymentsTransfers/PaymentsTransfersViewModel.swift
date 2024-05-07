//
//  PaymentsTransfersViewModel.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

final class PaymentsTransfersViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let navigationStateManager: NavigationStateManager
    private let rootActions: RootActions
    
    init(
        state: State,
        navigationStateManager: NavigationStateManager,
        rootActions: RootActions
    ) {
        self.state = state
        self.navigationStateManager = navigationStateManager
        self.rootActions = rootActions
    }
}

extension PaymentsTransfersViewModel {
    
    func startUtilityPaymentProcess() {
        
        event(.paymentButtonTapped(.utilityService))
    }
    
    func dismissDestination() {
        
        state.route.destination = nil
    }
    
    func event(_ event: Event) {
        
        let reduce = navigationStateManager.makeReduce { [weak self] in
            
            self?.event(.utilityFlow(.payment(.notified($0))))
        }
        let (route, effect) = reduce(state.route, event)
        
        if let outside = route.outside {
            
            self.state.route = .init()
            self.handleOutside(outside)
            
        } else {
            
            // routeSubject.send(state)
            DispatchQueue.main.async { [weak self] in
                
                self?.state.route = route
            }
            
            if let effect {
                
                rootActions.spinner.show()
                
                navigationStateManager.handleEffect(effect) { [weak self] in
                    
                    self?.rootActions.spinner.hide()
                    self?.event($0)
                }
            }
        }
    }
}

// MARK: - Types

extension PaymentsTransfersViewModel {
    
    struct State {
        
        var route: Route
    }
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
    typealias NavigationStateManager = PaymentsTransfersFlowManager
}

extension PaymentsTransfersViewModel.State {
    
    struct Route {
        
        var destination: Destination?
        var modal: Modal?
#warning("change to enum to make impossible simultaneous outside and destination/modal")
        var outside: Outside?
    }
}

extension PaymentsTransfersViewModel.State.Route {
    
    enum Destination {
        
        case payByInstructions
        case utilityPayment(UtilityPaymentFlowState)
    }
    
    enum Modal: Equatable {
        
        case paymentCancelled(expired: Bool)
    }
    
    enum Outside {
        
        case chat, main
    }
}

// MARK: - handle outside

private extension PaymentsTransfersViewModel {
    
    private func handleOutside(
        _ outside: State.Route.Outside
    ) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.3
        ) { [weak self] in
            
            switch outside {
            case .chat:
                self?.rootActions.switchTab("chat")
                
            case .main:
                self?.rootActions.switchTab("main")
            }
        }
    }
}
