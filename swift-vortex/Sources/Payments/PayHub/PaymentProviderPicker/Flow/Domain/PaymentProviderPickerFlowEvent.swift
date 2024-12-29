//
//  PaymentProviderPickerFlowEvent.swift
//
//
//  Created by Igor Malyarov on 31.08.2024.
//

public enum PaymentProviderPickerFlowEvent<Destination, Latest, Provider> {
    
    case dismiss
    case receive(PaymentProviderPickerFlowNavigation<Destination>)
    case select(Select)
    
    public typealias Select = PaymentProviderPickerFlowSelect<Latest, Provider>
}

extension PaymentProviderPickerFlowEvent: Equatable where Destination: Equatable, Latest: Equatable, Provider: Equatable {}

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
