//
//  PaymentFlowState.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

#warning("rename to `UtilityServicePaymentFlowState`")
struct PaymentFlowState {
    
    let viewModel: ViewModel
    var alert: Alert?
    var destination: Destination?
    var modal: Modal?
    
    init(
        viewModel: ViewModel,
        alert: Alert? = nil,
        destination: Destination? = nil,
        modal: Modal? = nil
    ) {
        self.viewModel = viewModel
        self.alert = alert
        self.destination = destination
        self.modal = modal
    }
}

extension PaymentFlowState {
    
    typealias ViewModel = ObservingPaymentFlowMockViewModel
}

extension PaymentFlowState {
    
    enum Alert {
        
        case terminalError(String)
    }
    
    enum Destination {
        
        
    }
    
    enum Modal {
        
        case fraud(Fraud)
    }
}

extension PaymentFlowState.Modal {
    
    struct Fraud: Equatable {}
}
