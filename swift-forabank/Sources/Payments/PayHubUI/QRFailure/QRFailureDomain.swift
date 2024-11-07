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
    
    struct Select {
        
        public let qrCode: QRCode
        public let selection: Selection
        
        public init(
            qrCode: QRCode, 
            selection: Selection
        ) {
            self.qrCode = qrCode
            self.selection = selection
        }
        
        public enum Selection {
            
            case search
            case payWithDetails
        }
    }
    
    enum Navigation {
        
        case categories(Result<Categories, Error>)
        case detailPayment(DetailPayment)
    }
}
