//
//  OperationPickerDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.11.2024.
//

import PayHub
import PayHubUI
import RxViewModel

/// A namespace/
enum OperationPickerDomain {}

extension OperationPickerDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias Composer = BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = OperationPickerContent
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHub.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    typealias Select = OperationPickerElement<Latest>
    typealias Navigation = OperationPickerNavigation
}

enum OperationPickerNavigation {
    
    case exchange(CurrencyWalletViewModel)
    case exchangeFailure
    case latest(PaymentsDomain.Navigation)
    case outside(Outside)
    case templates
    
    enum Outside: Equatable {
        
        case main
    }
}

// MARK: - Content

typealias OperationPickerContent = RxViewModel<OperationPickerState, OperationPickerEvent, OperationPickerEffect>

// MARK: - Domain

typealias OperationPickerState = PayHubUI.OperationPickerState<Latest>
typealias OperationPickerEvent = PayHubUI.OperationPickerEvent<Latest>
typealias OperationPickerEffect = PayHubUI.OperationPickerEffect
