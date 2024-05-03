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
    
    init(
        state: State,
        factory: Factory
    ) {
        self.state = state
        self.factory = factory
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
    
    enum Destination {}
    
    enum Modal {}
}
