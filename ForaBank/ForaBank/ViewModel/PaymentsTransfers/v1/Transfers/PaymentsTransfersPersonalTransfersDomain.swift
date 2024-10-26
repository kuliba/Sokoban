//
//  PaymentsTransfersPersonalTransfersDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.10.2024.
//

import PayHubUI

enum PaymentsTransfersPersonalTransfersDomain {
    
    typealias Binder = PlainPickerBinder<Select, NavigationResult>
    typealias BinderComposer = PlainPickerBinderComposer<Select, NavigationResult>
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, NavigationResult>
    
    typealias FlowState = FlowDomain.State
    typealias FlowEvent = FlowDomain.Event
    typealias FlowEffect = FlowDomain.Effect

    typealias NotifyEvent = FlowDomain.NotifyEvent
    
    typealias ButtonType = PTSectionTransfersView.ViewModel.TransfersButtonType
    
    enum Select {
        
        case alert(String)
        case buttonType(ButtonType)
        case contactAbroad(Payments.Operation.Source)
        case contacts(Payments.Operation.Source)
        case countries(Payments.Operation.Source)
        case latest(LatestPaymentData.ID)
        case qr(QR)
        case successMeToMe(Node<PaymentsSuccessViewModel>)
        
        enum QR: Equatable {
            
            case result(QRModelResult)
            case scan
        }
    }
    
    typealias NavigationResult = Result<Navigation, NavigationFailure>
    
    enum Navigation {
        
        case contacts(Node<ContactsViewModel>)
        case meToMe(Node<PaymentsMeToMeViewModel>)
        case payments(Node<ClosePaymentsViewModelWrapper>)
        case paymentsViewModel(Node<PaymentsViewModel>)
        case scanQR(Node<QRModel>)
        case successMeToMe(Node<PaymentsSuccessViewModel>)
    }
    
    enum NavigationFailure: Error, Equatable {
        
        case alert(String)
        case makeLatestFailure
        case makeMeToMeFailure
    }
}
