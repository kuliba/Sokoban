//
//  PaymentProviderPickerFlowState.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public struct PaymentProviderPickerFlowState<Destination> {
    
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
        
        case alert(BackendFailure)
        case destination(Destination)
        case outside(Outside)
    }
}

public extension PaymentProviderPickerFlowState.Navigation {
    
    enum Outside: Equatable {
        
        case back, chat, payments, qr
    }
}

extension PaymentProviderPickerFlowState: Equatable where Destination: Equatable {}
extension PaymentProviderPickerFlowState.Navigation: Equatable where Destination: Equatable {}
