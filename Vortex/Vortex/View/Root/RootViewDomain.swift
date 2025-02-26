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
    
    case openProduct(OpenProductType)
    case orderCardResponse(OpenCardDomain.OrderCardResponse)
    case orderSavingsAccountResponse(OpenSavingsAccountDomain.OrderAccountResponse)

    case outside(RootViewOutside)
    case scanQR
    case searchByUIN
    case standardPayment(ServiceCategory.CategoryType)
    case templates
    case userAccount
    case orderCardLanding
    
    enum RootViewOutside: Equatable {
        
        case productProfile(ProductData.ID)
        case tab(RootViewTab)
    }
}

enum RootViewTab: Equatable {
    
    case chat, main, payments
}

enum RootViewNavigation {
    
    case failure(Failure)
    case openProduct(OpenProduct)
    case orderCardResponse(OpenCardDomain.OrderCardResponse)
    case orderSavingsAccountResponse(OpenSavingsAccountDomain.OrderAccountResponse)

    case outside(RootViewOutside)
    case scanQR(Node<QRScannerDomain.Binder>)
    case searchByUIN(SearchByUIN)
    case standardPayment(Node<PaymentProviderPickerDomain.Binder>)
    case templates(TemplatesNode)
    case userAccount(UserAccountViewModel)
    case orderCardLanding(Node<OrderCardLandingDomain.Binder>)
    
    enum Failure {
        
        case featureFailure(FeatureFailure)
        case makeProductProfileFailure(ProductData.ID)
        case makeStandardPaymentFailure(ServiceCategoryFailureDomain.Binder)
        case makeUserAccountFailure
        case missingCategoryOfType(ServiceCategory.CategoryType)
    }
    
    enum RootViewOutside {
        
        case productProfile(ProductProfileViewModel)
        case tab(RootViewTab)
    }
    
    typealias SearchByUIN = SearchByUINDomain.Binder
    typealias Templates = PaymentsTransfersFactory.Templates
    typealias TemplatesNode = PaymentsTransfersFactory.TemplatesNode
}

struct FeatureFailure: Error, Equatable, Identifiable {
    
    let title: String
    let message: String
    
    init(
        title: String = "",
        message: String
    ) {
        self.title = title
        self.message = message
    }
    
    var id: Int { message.hashValue }
}
