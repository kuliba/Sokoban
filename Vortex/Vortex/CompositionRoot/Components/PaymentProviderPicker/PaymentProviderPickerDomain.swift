//
//  PaymentProviderPickerDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 24.09.2024.
//

import VortexTools
import PayHub
import PayHubUI

/// A namespace.
enum PaymentProviderPickerDomain {}

extension PaymentProviderPickerDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = PayHub.PaymentProviderPickerContent<OperationPicker, ProviderList, Search>
    
    typealias OperationPicker = Void
    typealias Search = RegularFieldViewModel
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHub.PaymentProviderPickerFlowDomain<DetailPayment, Latest, Payment, Provider, Service, ServicePicker, ServicesFailure>
    
    typealias Flow = FlowDomain.Flow
    
    typealias FlowReducer = FlowDomain.Reducer
    typealias FlowEffectHandler = FlowDomain.EffectHandler
    
    typealias Navigation = PaymentProviderPickerNavigation<DetailPayment, Payment, ServicePicker, ServicesFailure>
    
    typealias DetailPayment = ClosePaymentsViewModelWrapper
    typealias Payment = ProcessSelectionResult
    typealias Provider = UtilityPaymentProvider
    typealias Service = Void
    typealias ServicePicker = PaymentServicePicker.Binder
    typealias ServicesFailure = Void
    
    typealias ProcessSelectionResult = InitiateAnywayPaymentDomain.Result
    typealias InitiateAnywayPaymentDomain = Vortex.InitiateAnywayPaymentDomain<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService, Node<AnywayFlowModel>>
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
    
    typealias Binder = PayHub.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = Void
    
    // MARK: - Flow
    
    typealias Flow = Void
}
