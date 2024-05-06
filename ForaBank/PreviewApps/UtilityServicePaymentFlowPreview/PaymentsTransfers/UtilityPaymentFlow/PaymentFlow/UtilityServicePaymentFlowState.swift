//
//  UtilityServicePaymentFlowState.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 04.05.2024.
//

struct UtilityServicePaymentFlowState {
    
    let viewModel: ViewModel
    var alert: Alert?
    var fullScreenCover: FullScreenCover?
    var modal: Modal?
    
    init(
        viewModel: ViewModel,
        alert: Alert? = nil,
        fullScreenCover: FullScreenCover? = nil,
        modal: Modal? = nil
    ) {
        self.viewModel = viewModel
        self.alert = alert
        self.fullScreenCover = fullScreenCover
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
    
    enum FullScreenCover {
        
        case completed
    }
    
    enum Modal {
        
        case fraud(Fraud)
    }
}

extension UtilityServicePaymentFlowState.Modal {
    
    struct Fraud: Equatable {}
}
