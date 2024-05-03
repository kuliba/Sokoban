//
//  PaymentsTransfersViewModel.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import Foundation

final class PaymentsTransfersViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
    private let factory: Factory
    private let rootActions: RootActions
    
    init(
        state: State,
        factory: Factory,
        rootActions: RootActions
    ) {
        self.state = state
        self.factory = factory
        self.rootActions = rootActions
    }
}

extension PaymentsTransfersViewModel {
    
    func openUtilityPayment() {
        
        rootActions.spinner.show()
        
        factory.makeUtilityPaymentViewModel { [weak self] in
            
            self?.rootActions.spinner.hide()
            self?.state.route.destination = .utilityFlow($0)
        }
    }
    
    func resetDestination() {
        
        state.route.destination = nil
    }
}

// MARK: - Types

extension PaymentsTransfersViewModel {
    
    typealias Factory = PaymentsTransfersViewModelFactory
    
    struct State {
        
        var route: Route
    }
}

extension PaymentsTransfersViewModel.State {
    
    struct Route {
        
        var destination: Destination?
        var modal: Modal?
    }
}

extension PaymentsTransfersViewModel.State.Route {
    
    enum Destination {
        
        case utilityFlow(UtilityPaymentViewModel)
    }
    
    enum Modal {}
}

extension PaymentsTransfersViewModel.State.Route.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .utilityFlow(utilityPaymentViewModel):
            return .utilityFlow(ObjectIdentifier(utilityPaymentViewModel))
        }
    }
    
    enum ID: Hashable {
        
        case utilityFlow(ObjectIdentifier)
    }
}
