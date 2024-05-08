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
    
    private let flowManager: FlowManager
    private let rootActions: RootActions
    
    init(
        state: State,
        route: Route,
        flowManager: FlowManager,
        rootActions: RootActions
    ) {
        self.state = state
        self.route = route
        self.flowManager = flowManager
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
        
        let reduce = flowManager.makeReduce { [weak self] in
            
            self?.event(.utilityFlow(.payment(.notified($0))))
        }
        let (route, effect) = reduce(route, event)
        
        if let outside = route.outside {
            
            // routeSubject.send(route)
            self.route = .init()
            self.handleOutside(outside)
            
        } else {
            
            // routeSubject.send(route)
            DispatchQueue.main.async { [weak self] in self?.route = route }
            
            if let effect {
                
                rootActions.spinner.show()
                
                flowManager.handleEffect(effect) { [weak self] in
                    
                    self?.rootActions.spinner.hide()
                    self?.event($0)
                }
            }
        }
    }
}

// MARK: - Types

extension PaymentsTransfersViewModel {
    
    typealias Route = _Route<UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    
    struct _Route<UtilityPrepaymentViewModel, PaymentViewModel> {
        
        var destination: Destination?
        var modal: Modal?
        var outside: Outside?
    }
    
    struct State {}
    
    typealias Event = PaymentsTransfersEvent<UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    typealias Effect = PaymentsTransfersEffect<UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    
    typealias FlowManager = PaymentsTransfersFlowManager<UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
}

extension PaymentsTransfersViewModel._Route {
    
    enum Destination {
        
        case payByInstructions
        case utilityPayment(UtilityFlowState)
    }
    
    enum Modal: Equatable {
        
        case paymentCancelled(expired: Bool)
    }
    
    enum Outside {
        
        case chat, main
    }
}

extension PaymentsTransfersViewModel._Route.Destination {
    
    typealias UtilityFlowState = UtilityPaymentFlowState<UtilityPrepaymentViewModel, PaymentViewModel>
}

// MARK: - handle outside

private extension PaymentsTransfersViewModel {
    
    private func handleOutside(
        _ outside: Route.Outside
    ) {
        DispatchQueue.main.delay(for: .milliseconds(300)) { [weak self] in
            
            switch outside {
            case .chat:
                self?.rootActions.switchTab("chat")
                
            case .main:
                self?.rootActions.switchTab("main")
            }
        }
    }
}
