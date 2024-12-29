//
//  PaymentProviderPickerFlowEvent.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public typealias PaymentProviderPickerFlowEvent<Destination, Latest, Provider> = FlowEvent<PaymentProviderPickerFlowSelect<Latest, Provider>, PaymentProviderPickerFlowNavigation<Destination>>

public enum PaymentProviderPickerFlowSelect<Latest, Provider> {
    
    case detailPayment
    case latest(Latest)
    case outside(PaymentProviderPickerFlowOutside)
    case provider(Provider)
}

public enum PaymentProviderPickerFlowNavigation<Destination> {
    
    case alert(BackendFailure)
    case destination(Destination)
    case outside(PaymentProviderPickerFlowOutside)
}

extension PaymentProviderPickerFlowNavigation: Equatable where Destination: Equatable {}

extension PaymentProviderPickerFlowSelect: Equatable where Latest: Equatable, Provider: Equatable {}

public enum PaymentProviderPickerFlowOutside: Equatable {
    
    case back
    case chat
    case main
    case payments
    case qr
}
