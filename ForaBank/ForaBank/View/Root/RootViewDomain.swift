//
//  RootViewDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2024.
//

import PayHubUI

typealias RootViewDomain = PayHubUI.RootViewDomain<RootViewModel, RootViewModelAction.DismissAll, RootViewSelect, RootViewNavigation>

enum RootViewSelect: Equatable {
    
    case scanQR
    case templates
}

enum RootViewNavigation {
    
    case scanQR(Node<QRScannerDomain.Binder>)
    case templates
}
