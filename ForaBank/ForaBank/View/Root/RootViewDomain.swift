//
//  RootViewDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2024.
//

import PayHubUI

typealias RootViewDomain = PayHubUI.RootViewDomain<RootViewModel, RootViewModelAction.DismissAll, RootViewSelect, RootViewNavigation>

extension RootViewDomain {
    
    typealias Outside = RootViewOutside
    typealias Select = RootViewSelect
    typealias Navigation = RootViewNavigation
}

enum RootViewSelect: Equatable {
    
    case outside(RootViewOutside)
    case scanQR
    case standardPayment
    case templates
}

enum RootViewOutside: Equatable {
    
    case productProfile(ProductData.ID)
    case tab(Tab)
    
    enum Tab: Equatable {
        
        case main, payments
    }
}

enum RootViewNavigation {
    
    case outside(RootViewOutside)
    case scanQR(Node<QRScannerDomain.Binder>)
    case standardPayment
    case templates(TemplatesNode)
    
    typealias Templates = PaymentsTransfersFactory.Templates
    typealias TemplatesNode = PaymentsTransfersFactory.TemplatesNode
}
