//
//  PaymentProviderPickerFlowState.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

import ForaTools

public struct PaymentProviderPickerFlowState<PayByInstructions, Payment, Service> {
    
    public var isLoading: Bool
    public var navigation: Navigation?
    
    public init(
        isLoading: Bool = false,
        navigation: Navigation? = nil
    ) {
        self.isLoading = isLoading
        self.navigation = navigation
    }
}

public extension PaymentProviderPickerFlowState {
    
    enum Navigation {
        
        case alert(ServiceFailure)
        case destination(Destination)
        case outside(Outside)
    }
}

public extension PaymentProviderPickerFlowState.Navigation {
    
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

public extension PaymentProviderPickerFlowState.Navigation.Destination {
 
    typealias Services = MultiElementArray<Service>
}

extension PaymentProviderPickerFlowState: Equatable where PayByInstructions: Equatable, Payment: Equatable, Service: Equatable {}
extension PaymentProviderPickerFlowState.Navigation: Equatable where PayByInstructions: Equatable, Payment: Equatable, Service: Equatable {}
extension PaymentProviderPickerFlowState.Navigation.Destination: Equatable where PayByInstructions: Equatable, Payment: Equatable, Service: Equatable {}
