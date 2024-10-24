//
//  PaymentsTransfersPersonalTransfersDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2024.
//

import PayHubUI

enum PaymentsTransfersPersonalTransfersDomain {
    
    typealias ButtonType = PTSectionTransfersView.ViewModel.TransfersButtonType
    
    enum Element: Equatable {
        
        case buttonType(ButtonType)
        case contacts(Payments.Operation.Source)
        case countries(Payments.Operation.Source)
        case latest(LatestPaymentData.ID)
        case scanQR
    }
    
    enum Navigation {
        
        case contacts(Node<ContactsViewModel>)
        case meToMe(Node<PaymentsMeToMeViewModel>)
        case payments(Node<ClosePaymentsViewModelWrapper>)
        case paymentsViewModel(Node<PaymentsViewModel>)
    }
    
    typealias Binder = PlainPickerBinder<Element, Navigation>
    typealias BinderComposer = PlainPickerBinderComposer<Element, Navigation>
    
    typealias FlowDomain = PayHubUI.FlowDomain<Element, Navigation>
    
    typealias FlowState = FlowDomain.State
    typealias FlowEvent = FlowDomain.Event
    typealias FlowEffect = FlowDomain.Effect
}
