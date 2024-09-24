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
    
    // MARK: - Domains
    
    typealias FlowDomain = PayHub.PaymentProviderPickerFlowDomain<DetailPayment, Latest, Payment, Provider, Service, ServicePicker, ServicesFailure>
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = PayHub.PaymentProviderPickerContent<OperationPicker, ProviderList, Search>
    
    typealias OperationPicker = Void
    typealias Search = Void
    
    // MARK: - Flow
    
    typealias Flow = FlowDomain.Flow
    
    typealias FlowReducer = FlowDomain.Reducer
    typealias FlowEffectHandler = FlowDomain.EffectHandler
    
    typealias DetailPayment = Void
    typealias Payment = Void
    typealias Provider = PaymentServiceOperator
    typealias Service = Void
    typealias ServicePicker = Void
    typealias ServicesFailure = Void
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
