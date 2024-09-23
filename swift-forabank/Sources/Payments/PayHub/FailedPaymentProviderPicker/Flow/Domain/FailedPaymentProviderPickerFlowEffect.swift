//
//  FailedPaymentProviderPickerFlowEffect.swift
//  
//
//  Created by Igor Malyarov on 23.09.2024.
//

public enum FailedPaymentProviderPickerFlowEffect: Equatable {
    
    case select(Selection)
}

public extension FailedPaymentProviderPickerFlowEffect {
    
    enum Selection: Equatable {
        
        case detailPay
    }
}
