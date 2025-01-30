//
//  PaymentsTransfersPersonalTransfersDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.10.2024.
//

import PayHub
import PayHubUI

enum PaymentsTransfersPersonalTransfersDomain {
    
    // MARK: - Binder
    
    typealias Binder = PlainPickerBinder<Select, Navigation>
    
    typealias FlowDomain = Vortex.FlowDomain<Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = PlainPickerContent<Select>
    
    // MARK: - Flow
    
    typealias FlowState = FlowDomain.State
    typealias FlowEvent = FlowDomain.Event
    typealias FlowEffect = FlowDomain.Effect
    
    typealias Notify = FlowDomain.Notify
    typealias NotifyEvent = FlowDomain.NotifyEvent
    
    typealias ButtonType = PTSectionTransfersView.ViewModel.TransfersButtonType
    
    enum Select {
        
        case alert(String)
        case buttonType(ButtonType)
        case contactAbroad(Payments.Operation.Source)
        case contacts(Payments.Operation.Source)
        case countries(Payments.Operation.Source)
        case latest(LatestPaymentData.ID)
        case scanQR
        case successMeToMe(Node<PaymentsSuccessViewModel>)
    }
    
    typealias Navigation = Result<NavigationSuccess, NavigationFailure>
    
    enum NavigationSuccess {
        
        case contacts(Node<ContactsViewModel>)
        case meToMe(Node<PaymentsMeToMeViewModel>)
        case payments(Node<ClosePaymentsViewModelWrapper>)
        case paymentsViewModel(Node<PaymentsViewModel>)
        case scanQR
        case successMeToMe(Node<PaymentsSuccessViewModel>)
    }
    
    enum NavigationFailure: Error, Equatable {
        
        case alert(String)
        case makeLatestFailure
        case makeMeToMeFailure
    }
}
