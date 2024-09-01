//
//  PaymentProviderPickerFlowState.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

struct PaymentProviderPickerFlowState: Equatable {
    
    var isLoading: Bool
    var navigation: Navigation?
}

extension PaymentProviderPickerFlowState {
    
    enum Navigation: Equatable {
        
        case outside(Outside)
    }
}

extension PaymentProviderPickerFlowState.Navigation {
    
    enum Outside: Equatable {
        
        case back, chat, qr
    }
}
// extension PaymentProviderPickerFlowState: Equatable {}
