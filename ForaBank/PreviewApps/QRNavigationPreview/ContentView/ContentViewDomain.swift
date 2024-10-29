//
//  ContentViewDomain.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import PayHubUI

typealias ContentViewDomain = PayHubUI.FlowDomain<ContentViewSelect, ContentViewNavigation>

enum ContentViewSelect {
    
    case qrNavigation(QRNavigation)
    case scanQR
}

enum ContentViewNavigation {
    
    case qr(Node<QRDomain.Binder>)
    case qrNavigation(QRNavigation)
}
