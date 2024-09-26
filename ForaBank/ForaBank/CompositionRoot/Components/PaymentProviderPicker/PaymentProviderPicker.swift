//
//  PaymentProviderPicker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.09.2024.
//

import PayHub
import PayHubUI

/// A namespace.
enum PaymentProviderPicker {}

extension PaymentProviderPicker {
    
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
    
    typealias DetailPayment = ClosePaymentsViewModelWrapper
    typealias Payment = Void
    typealias Provider = PaymentServiceOperator
    typealias Service = Void
    typealias ServicePicker = PaymentServicePicker.Binder
    typealias ServicesFailure = Void
    
    typealias Destination = PaymentProviderPickerDestination<DetailPayment, Payment, ServicePicker, ServicesFailure>
}

// MARK: - ProviderList

import RxViewModel
import UtilityServicePrepaymentCore
import UtilityServicePrepaymentDomain

extension PaymentProviderPicker {
    
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
