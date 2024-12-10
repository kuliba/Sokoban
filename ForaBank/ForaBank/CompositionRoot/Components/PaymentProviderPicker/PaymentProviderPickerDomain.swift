//
//  PaymentProviderPickerDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.09.2024.
//

import ForaTools
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
    typealias Provider = PaymentServiceOperator
    typealias Service = Void
    typealias ServicePicker = PaymentServicePicker.Binder
    typealias ServicesFailure = Void
    
    typealias _ProcessSelectionResult = UtilityPrepaymentFlowEvent<UtilityPaymentLastPayment, UtilityPaymentProvider, UtilityService>.ProcessSelectionResult
    
    typealias ProcessSelectionResult = Result<ProcessSelectionSuccess, ProcessSelectionFailure>
    
    enum ProcessSelectionSuccess {
        
        case services(MultiElementArray<UtilityService>, for: UtilityPaymentProvider)
        case anywayPayment(AnywayFlowModel)
    }
    
    enum ProcessSelectionFailure: Error {
        
        case operatorFailure(UtilityPaymentProvider)
        case serviceFailure(ServiceFailure)
        
#warning("extract…")
        enum ServiceFailure: Error, Hashable {
            
            case connectivityError
            case serverError(String)
        }
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
    
    typealias Binder = PayHub.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = Void
    
    // MARK: - Flow
    
    typealias Flow = Void
}
