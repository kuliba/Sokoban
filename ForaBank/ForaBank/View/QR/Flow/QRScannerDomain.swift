//
//  QRScannerDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.11.2024.
//

import PayHub
import PayHubUI

/// A namespace.
enum QRScannerDomain {}

extension QRScannerDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias BinderComposer = PayHubUI.BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = QRScannerModel
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    typealias NotifyEvent = FlowDomain.NotifyEvent
    typealias Notify = (NotifyEvent) -> Void
    
    enum Outside: Equatable {
        
        case chat, main, payments
    }
    
    enum Select: Equatable {
    
        case outside(Outside)
        case qrResult(QRModelResult)
    }
    
    enum Navigation {
        
        case failure(QRFailedViewModelWrapper)
        case outside(Outside)
        case payments(Node<PaymentsViewModel>)
    }
}
