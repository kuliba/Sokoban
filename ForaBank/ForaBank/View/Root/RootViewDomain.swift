//
//  RootViewDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2024.
//

import PayHubUI

typealias RootViewDomain = PayHubUI.RootViewDomain<RootViewModel, RootViewModelAction.DismissAll, RootViewSelect, RootViewNavigation>

extension RootViewDomain {
    
    typealias Select = RootViewSelect
    typealias Navigation = RootViewNavigation
}

enum RootViewSelect: Equatable {
    
    case productProfile(ProductData.ID)
    case scanQR
    case tab(Tab)
    case templates
    
    enum Tab: Equatable {
        
        case main, payments
    }
}

enum RootViewNavigation {
    
    case scanQR(Node<QRScannerDomain.Binder>)
    case templates(TemplatesNode)
    
    typealias Templates = PaymentsTransfersFactory.Templates
    typealias TemplatesNode = PaymentsTransfersFactory.TemplatesNode
}
