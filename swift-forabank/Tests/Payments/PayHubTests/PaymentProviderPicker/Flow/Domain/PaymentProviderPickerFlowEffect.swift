//
//  PaymentProviderPickerFlowEffect.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

enum PaymentProviderPickerFlowEffect<Latest, Provider> {
    
    case select(Select)
}

extension PaymentProviderPickerFlowEffect {
    
    enum Select {
        
        case latest(Latest)
        case payByInstructions
        case provider(Provider)
    }
}

extension PaymentProviderPickerFlowEffect: Equatable where Latest: Equatable, Provider: Equatable {}
extension PaymentProviderPickerFlowEffect.Select: Equatable where Latest: Equatable, Provider: Equatable {}
