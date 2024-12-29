//
//  PaymentProviderPickerFlowDomain.swift
//
//
//  Created by Igor Malyarov on 24.09.2024.
//

public typealias PaymentProviderPickerFlowDomain<DetailPayment, Latest, Payment, Provider, Service, ServicePicker, ServicesFailure> = FlowDomain<PaymentProviderPickerFlowSelect<Latest, Provider>, PaymentProviderPickerFlowNavigation<PaymentProviderPickerDestination<DetailPayment, Payment, ServicePicker, ServicesFailure>>>

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

public enum PaymentProviderPickerFlowOutside: Equatable {
    
    case back
    case chat
    case main
    case payments
    case qr
}

extension PaymentProviderPickerFlowSelect: Equatable where Latest: Equatable, Provider: Equatable {}

extension PaymentProviderPickerFlowNavigation: Equatable where Destination: Equatable {}

public enum PaymentProviderPickerDestination<DetailPayment, Payment, ServicePicker, ServicesFailure> {
    
    case backendFailure(BackendFailure)
    case detailPayment(DetailPayment)
    case payment(Payment)
    case servicePicker(ServicePicker)
    case servicesFailure(ServicesFailure)
}

extension PaymentProviderPickerDestination: Equatable where DetailPayment: Equatable, Payment: Equatable, ServicePicker: Equatable, ServicesFailure: Equatable {}
