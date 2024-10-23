//
//  PaymentsTransfersPersonalTransfersDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2024.
//

import PayHubUI

enum PaymentsTransfersPersonalTransfersDomain {
    
    typealias Element = PTSectionTransfersView.ViewModel.TransfersButtonType
    
    #warning("temporary conformance to Identifiable")
    enum Navigation: Identifiable {
        
        var id: Int { 1 }
        
        case contacts(Node<ContactsViewModel>)
        case meToMe(Node<PaymentsMeToMeViewModel>)
        case payments(Node<ClosePaymentsViewModelWrapper>)
    }
    
    typealias Binder = PlainPickerBinder<Element, Navigation>
    typealias BinderComposer = PlainPickerBinderComposer<Element, Navigation>
}
