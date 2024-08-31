//
//  PaymentProviderPickerFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 31.08.2024.
//

enum PaymentProviderPickerFlowEvent<Latest, Provider> {
    
    case select(Select)
}

extension PaymentProviderPickerFlowEvent {
    
    enum Select {
        
        case back
        case chat
        case latest(Latest)
        case payByInstructions
        case provider(Provider)
        case qr
    }
}

extension PaymentProviderPickerFlowEvent: Equatable where Latest: Equatable, Provider: Equatable {}
extension PaymentProviderPickerFlowEvent.Select: Equatable where Latest: Equatable, Provider: Equatable {}
