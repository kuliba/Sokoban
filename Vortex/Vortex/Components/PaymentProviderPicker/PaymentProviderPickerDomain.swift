//
//  PaymentProviderPickerDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 24.09.2024.
//

import PayHub
import PayHubUI
import RxViewModel
import UtilityServicePrepaymentCore
import UtilityServicePrepaymentDomain
import VortexTools

typealias BackendFailure = PayHub.BackendFailure

/// A namespace.
enum PaymentProviderPickerDomain {}

extension PaymentProviderPickerDomain {
    
    // MARK: - Binder
    
    typealias Binder = Vortex.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = PayHub.PaymentProviderPickerContent<OperationPicker, ProviderList, Search>
    
    typealias OperationPicker = OperationPickerDomain.Content
    typealias Search = RegularFieldViewModel
    
    // MARK: - Flow
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias DetailPayment = Node<PaymentsViewModel>
    typealias Payment = ProcessSelectionResult
    typealias Provider = UtilityPaymentProvider
    typealias ServicePicker = PaymentServicePicker.Binder
    typealias ServicesFailure = ServiceCategoryFailureDomain.Binder
    
    typealias ProcessSelectionResult = InitiateAnywayPaymentDomain.Result
    typealias InitiateAnywayPaymentDomain = Vortex.InitiateAnywayPaymentDomain<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService, Node<ProviderServicePickerDomain.Binder>, Node<AnywayFlowModel>>
    
    enum Select: Equatable {
        
        case detailPayment
        case latest(Latest)
        case outside(Outside)
        case provider(Provider)
    }
    
    enum Outside: Equatable {
        
        case back
        case chat
        case main
        case payments
        case qr
    }
    
    enum Navigation {
        
        case alert(BackendFailure)
        case destination(Destination)
        case outside(Outside)
    }
    
    enum Destination {
        
        case detailPayment(DetailPayment)
        case payment(Payment)
        case servicePicker(ServicePicker)
        case servicesFailure(ServicesFailure)
    }
}

extension PaymentProviderPickerDomain {
    
    // MARK: - ProviderList
    
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
