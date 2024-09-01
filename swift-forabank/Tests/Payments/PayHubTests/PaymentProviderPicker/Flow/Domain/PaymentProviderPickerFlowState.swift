//
//  PaymentProviderPickerFlowState.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

import ForaTools

struct PaymentProviderPickerFlowState<PayByInstructions, Payment, Service> {
    
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
        
        case payByInstructions(PayByInstructions)
        case payment(Payment)
        case services(Services)
        case servicesFailure
    }
    
    enum Outside: Equatable {
        
        case back, chat, qr
    }
}

extension PaymentProviderPickerFlowState.Navigation.Destination {
 
    typealias Services = MultiElementArray<Service>
}

extension PaymentProviderPickerFlowState: Equatable where PayByInstructions: Equatable, Payment: Equatable, Service: Equatable {}
extension PaymentProviderPickerFlowState.Navigation: Equatable where PayByInstructions: Equatable, Payment: Equatable, Service: Equatable {}
extension PaymentProviderPickerFlowState.Navigation.Destination: Equatable where PayByInstructions: Equatable, Payment: Equatable, Service: Equatable {}
