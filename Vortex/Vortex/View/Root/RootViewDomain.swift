//
//  RootViewDomain.swift
//  Vortex
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
    
    case outside(RootViewOutside)
    case scanQR
    case userAccount
    case standardPayment(ServiceCategory.CategoryType)
    case templates
    
    enum RootViewOutside: Equatable {
        
        case productProfile(ProductData.ID)
        case tab(RootViewTab)
    }
}

enum RootViewTab: Equatable {
    
    case main, payments
}

enum RootViewNavigation {
    
    case failure(Failure)
    case outside(RootViewOutside)
    case scanQR(Node<QRScannerDomain.Binder>)
    case standardPayment(Node<PaymentProviderPickerDomain.Binder>)
    case templates(TemplatesNode)
    case userAccount(UserAccountViewModel)
    
    enum Failure {
        
        case makeProductProfileFailure(ProductData.ID)
        case makeStandardPaymentFailure(ServiceCategoryFailureDomain.Binder)
        case makeUserAccountFailure
        case missingCategoryOfType(ServiceCategory.CategoryType)
    }
    
    enum RootViewOutside {
        
        case productProfile(ProductProfileViewModel)
        case tab(RootViewTab)
    }
    
    typealias Templates = PaymentsTransfersFactory.Templates
    typealias TemplatesNode = PaymentsTransfersFactory.TemplatesNode
}
