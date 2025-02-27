//
//  OpenProduct.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

enum OpenProduct {
    
    case card(OpenCardType)
    case creditCardMVP(CreditCardMVPDomain.Binder)
    case savingsAccount(SavingsAccountNodes)
    case unknown // TODO: replace with other types
    
    enum OpenCardType {
        
        case landing(OrderCardLandingDomain.Binder)
        case form(Form)
        
        typealias Form = Node<OpenCardDomain.Binder>
    }
}
