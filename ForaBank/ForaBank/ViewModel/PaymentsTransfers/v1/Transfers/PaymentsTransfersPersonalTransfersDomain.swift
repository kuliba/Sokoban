//
//  PaymentsTransfersPersonalTransfersDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2024.
//

import PayHubUI

enum PaymentsTransfersPersonalTransfersDomain {
    
    typealias ButtonType = PTSectionTransfersView.ViewModel.TransfersButtonType
    
    enum Element {
        
        case buttonType(ButtonType)
    }
    
    enum Navigation {
        
        case contacts(Node<ContactsViewModel>)
        case meToMe(Node<PaymentsMeToMeViewModel>)
        case payments(Node<ClosePaymentsViewModelWrapper>)
    }
    
    typealias Binder = PlainPickerBinder<Element, Navigation>
    typealias BinderComposer = PlainPickerBinderComposer<Element, Navigation>
    
    typealias FlowDomain = PayHubUI.FlowDomain<Element, Navigation>
    
    typealias FlowState = FlowDomain.State
    typealias FlowEvent = FlowDomain.Event
    typealias FlowEffect = FlowDomain.Effect
}
