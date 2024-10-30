//
//  QRButtonDomain.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import PayHubUI

enum QRButtonDomain {
    
    typealias FlowDomain = PayHubUI.FlowDomain<Select, Navigation>
    
    enum Select {
        
        case qrNavigation(QRNavigation)
        case scanQR
    }
    
    enum Navigation {
        
        case qr(QRDomain.Binder)
        case qrNavigation(QRNavigation)
    }
}
