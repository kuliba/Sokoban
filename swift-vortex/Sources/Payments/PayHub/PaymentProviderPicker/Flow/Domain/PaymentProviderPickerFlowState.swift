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
    
    typealias Navigation = PaymentProviderPickerFlowNavigation<Destination>
}

extension PaymentProviderPickerFlowState: Equatable where Destination: Equatable {}
