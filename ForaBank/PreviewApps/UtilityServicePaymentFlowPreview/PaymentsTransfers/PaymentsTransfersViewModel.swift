//
//  PaymentsTransfersViewModel.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

final class PaymentsTransfersViewModel: ObservableObject {
    
    @Published private(set) var state: State
    @Published private(set) var route: Route
    
    private let navigationStateManager: NavigationStateManager
    private let rootActions: RootActions
    
    init(
        state: State,
        route: Route,
        navigationStateManager: NavigationStateManager,
        rootActions: RootActions
    ) {
        self.state = state
        self.route = route
        self.navigationStateManager = navigationStateManager
        self.rootActions = rootActions
    }
}

extension PaymentsTransfersViewModel {
    
    func startUtilityPaymentProcess() {
        
        event(.paymentButtonTapped(.utilityService))
    }
    
    func dismissDestination() {
        
        route.destination = nil
    }
    
    func event(_ event: Event) {
        
        let reduce = navigationStateManager.makeReduce { [weak self] in
            
            self?.event(.utilityFlow(.payment(.notified($0))))
        }
        let (route, effect) = reduce(route, event)
        
        if let outside = route.outside {
            
            self.route = .init()
            self.handleOutside(outside)
            
        } else {
            
            // routeSubject.send(state)
            DispatchQueue.main.async { [weak self] in
                
                self?.route = route
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
    
    struct Route {
        
        var destination: Destination?
        var modal: Modal?
        var outside: Outside?
    }

    struct State {}
    
    typealias Event = PaymentsTransfersEvent
    typealias Effect = PaymentsTransfersEffect
    typealias NavigationStateManager = PaymentsTransfersFlowManager
}

extension PaymentsTransfersViewModel.Route {
    
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
        _ outside: Route.Outside
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
