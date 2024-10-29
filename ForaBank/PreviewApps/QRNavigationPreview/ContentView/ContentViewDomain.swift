//
//  ContentViewDomain.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import PayHubUI

typealias ContentViewDomain = PayHubUI.FlowDomain<ContentViewSelect, ContentViewNavigation>

enum ContentViewSelect: Equatable {
    
    case scanQR
}

enum ContentViewNavigation {
    
    case qr(QRDomain.Binder)
}
