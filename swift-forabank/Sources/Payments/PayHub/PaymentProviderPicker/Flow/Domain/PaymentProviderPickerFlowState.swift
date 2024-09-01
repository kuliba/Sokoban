//
//  PaymentProviderPickerFlowState.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

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
    
    typealias Destination = PaymentProviderPickerFlowDestination<PayByInstructions, Payment, Service>
}

public extension PaymentProviderPickerFlowState.Navigation {
    
    enum Outside: Equatable {
        
        case back, chat, payments, qr
    }
}

extension PaymentProviderPickerFlowState: Equatable where PayByInstructions: Equatable, Payment: Equatable, Service: Equatable {}
extension PaymentProviderPickerFlowState.Navigation: Equatable where PayByInstructions: Equatable, Payment: Equatable, Service: Equatable {}
