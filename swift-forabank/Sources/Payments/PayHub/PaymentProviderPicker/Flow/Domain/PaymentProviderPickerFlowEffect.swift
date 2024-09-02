//
//  PaymentProviderPickerFlowEffect.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

public enum PaymentProviderPickerFlowEffect<Latest, Provider> {
    
    case select(Select)
}

public extension PaymentProviderPickerFlowEffect {
    
    enum Select {
        
        case detailPayment
        case latest(Latest)
        case provider(Provider)
    }
}

extension PaymentProviderPickerFlowEffect: Equatable where Latest: Equatable, Provider: Equatable {}
extension PaymentProviderPickerFlowEffect.Select: Equatable where Latest: Equatable, Provider: Equatable {}
