//
//  PaymentFlowState.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

struct PaymentFlowState {
    
    let viewModel: ViewModel
    var destination: Destination?
    var modal: Modal?
    
    init(
        viewModel: ViewModel,
        destination: Destination? = nil,
        modal: Modal? = nil
    ) {
        self.viewModel = viewModel
        self.destination = destination
        self.modal = modal
    }
    
    typealias ViewModel = PaymentFlowMockViewModel
}

extension PaymentFlowState {
    
    enum Destination {
        
        
    }
    
    enum Modal {
        
        case fraud(Fraud)
    }
}

extension PaymentFlowState.Modal {
    
    struct Fraud: Equatable {}
}
