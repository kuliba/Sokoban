//
//  QRFailureDomain.swift
//
//
//  Created by Igor Malyarov on 06.11.2024.
//

import PayHub

/// A namespace.
public enum QRFailureDomain<QRCode, QRFailure, Categories, DetailPayment> {}

public extension QRFailureDomain {
    
    // MARK: - Binder
    
    typealias Binder = PayHub.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = QRFailure
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias FlowComposer = FlowDomain.Composer
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    
    enum Select {
        
        case scanQR
        case payWithDetails(QRCode)
        case search(QRCode)
    }
    
    enum Navigation {
        
        case categories(Result<Categories, Error>)
        case detailPayment(Node<DetailPayment>)
        case scanQR
    }
}
