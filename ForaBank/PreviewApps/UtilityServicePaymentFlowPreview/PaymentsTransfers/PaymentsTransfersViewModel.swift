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
    
    typealias Route = _Route<LastPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    typealias Destination = _Destination<LastPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    
    struct _Route<LastPayment, Operator, UtilityService, Content, PaymentViewModel> {
        
        var destination: _Destination<LastPayment, Operator, UtilityService, Content, PaymentViewModel>?
        var modal: Modal?
        var outside: Outside?
    }
    
    enum _Destination<LastPayment, Operator, UtilityService, Content, PaymentViewModel> {
        
        case payByInstructions
        case utilityPayment(UtilityFlowState)
    }
    
    enum Modal: Equatable {
        
        case paymentCancelled(expired: Bool)
    }
    
    enum Outside {
        
        case chat, main
    }
    
    struct State {}
    
    typealias Event = PaymentsTransfersFlowEvent<LastPayment, Operator, UtilityService>
    typealias Effect = PaymentsTransfersFlowEffect<LastPayment, Operator, UtilityService>
    
    typealias FlowManager = PaymentsTransfersFlowManager<LastPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
}

extension PaymentsTransfersViewModel._Destination {
    
    typealias UtilityFlowState = UtilityPaymentFlowState<LastPayment, Operator, UtilityService, Content, PaymentViewModel>
}

// MARK: - handle outside

private extension PaymentsTransfersViewModel {
    
    private func handleOutside(
        _ outside: Outside
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
