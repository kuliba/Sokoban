//
//  UtilityServicePaymentFlowState.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

struct UtilityServicePaymentFlowState {
    
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

extension UtilityServicePaymentFlowState {
    
    typealias ViewModel = ObservingPaymentFlowMockViewModel
}

extension UtilityServicePaymentFlowState {
    
    enum Alert {
        
        case terminalError(String)
    }
    
    enum Destination {
        
        
    }
    
    enum Modal {
        
        case fraud(Fraud)
    }
}

extension UtilityServicePaymentFlowState.Modal {
    
    struct Fraud: Equatable {}
}
