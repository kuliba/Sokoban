//
//  PaymentsTransfersPersonalToolbarDomain.swift
//
//
//  Created by Igor Malyarov on 22.11.2024.
//

import PayHub

/// A namespace.
public enum PaymentsTransfersPersonalToolbarDomain<Profile, QR> {}

public extension PaymentsTransfersPersonalToolbarDomain {
    
    // MARK: - Binder
    typealias Binder = PayHub.Binder<Content, Flow>
    typealias Composer = BinderComposer<Content, Select, Navigation>
    
    // MARK: - Content
    
    typealias Content = PaymentsTransfersPersonalToolbarContent
    
    // MARK: - Flow
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    
    enum Select {
        
        case profile, qr
    }
    
    enum Navigation {
        
        case profile(Profile)
        case qr(QR)
    }
}
