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
    typealias ProviderList = Void
    typealias Search = Void
    
    // MARK: - Flow
    
    typealias Flow = PayHubUI.PaymentProviderPickerFlow<DetailPayment, Latest, Payment, Provider, Service, ServicePicker, ServicesFailure>
    
    typealias DetailPayment = Void
    typealias Payment = Void
    typealias Provider = PaymentServiceOperator
    typealias Service = Void
    typealias ServicePicker = Void
    typealias ServicesFailure = Void
}
