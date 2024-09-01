//
//  PaymentProviderPickerFlowState.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

struct PaymentProviderPickerFlowState<Payment> {
    
    var isLoading: Bool
    var navigation: Navigation?
}

extension PaymentProviderPickerFlowState {
    
    enum Navigation {
        
        case alert(ServiceFailure)
        case destination(Destination)
        case outside(Outside)
    }
}

extension PaymentProviderPickerFlowState.Navigation {
    
    enum Destination {
        
        case payment(Payment)
    }
    
    enum Outside: Equatable {
        
        case back, chat, qr
    }
}
extension PaymentProviderPickerFlowState: Equatable where Payment: Equatable {}
extension PaymentProviderPickerFlowState.Navigation: Equatable where Payment: Equatable {}
extension PaymentProviderPickerFlowState.Navigation.Destination: Equatable where Payment: Equatable {}
