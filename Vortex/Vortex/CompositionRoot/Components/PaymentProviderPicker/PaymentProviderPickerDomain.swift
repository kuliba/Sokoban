//
//  PaymentProviderPickerDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 24.09.2024.
//

import PayHub
import PayHubUI
import VortexTools

/// A namespace.
enum PaymentProviderPickerDomain {}

extension PaymentProviderPickerDomain {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = PayHub.PaymentProviderPickerContent<OperationPicker, ProviderList, Search>
    
    typealias OperationPicker = Void
    typealias Search = RegularFieldViewModel
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias FlowReducer = FlowDomain.Reducer
    typealias FlowEffectHandler = FlowDomain.EffectHandler
    
    typealias DetailPayment = Node<PaymentsViewModel>
    typealias Payment = ProcessSelectionResult
    typealias Provider = UtilityPaymentProvider
    typealias Service = Void
    typealias ServicePicker = PaymentServicePicker.Binder
    typealias ServicesFailure = Void
    
    typealias ProcessSelectionResult = InitiateAnywayPaymentDomain.Result
    typealias OperatorServices = Vortex.OperatorServices<UtilityPaymentProvider, UtilityService>
    typealias InitiateAnywayPaymentDomain = Vortex.InitiateAnywayPaymentDomain<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService, ProviderServicePickerDomain.Binder, Node<AnywayFlowModel>>
    
    enum Select: Equatable {
        
        case detailPayment
        case latest(Latest)
        case outside(PaymentProviderPickerFlowOutside)
        case provider(Provider)
    }
    
    enum Navigation {
        
        case alert(BackendFailure)
        case destination(Destination)
        case outside(PaymentProviderPickerFlowOutside)
    }
    
    enum PaymentProviderPickerFlowOutside: Equatable {
        
        case back
        case chat
        case main
        case payments
        case qr
    }
    
    enum Destination {
        
        case backendFailure(BackendFailure)
        case detailPayment(DetailPayment)
        case payment(Payment)
        case servicePicker(ServicePicker)
        case servicesFailure(ServicesFailure)
    }
}

// MARK: - ProviderList

import RxViewModel
import UtilityServicePrepaymentCore
import UtilityServicePrepaymentDomain

extension PaymentProviderPickerDomain {
    
    typealias ProviderList = RxViewModel<ProviderListState, ProviderListEvent, ProviderListEffect>
    
    typealias ProviderListState = PrepaymentPickerSuccess<Latest, Provider>
    typealias ProviderListEvent = PrepaymentPickerEvent<Provider>
    typealias ProviderListEffect = PrepaymentPickerEffect<Provider.ID>
    
    typealias ProviderListReducer = PrepaymentSuccessPickerReducer<Latest, Provider>
    typealias ProviderListEffectHandler = PrepaymentPickerEffectHandler<Provider>
}

// MARK: - ServicePicker

/// A namespace.
enum PaymentServicePicker {}

extension PaymentServicePicker {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = Void
    
    // MARK: - Flow
    
    typealias Flow = Void
}
