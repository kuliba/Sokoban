//
//  OpenProduct.swift
//  Vortex
//
//  Created by Igor Malyarov on 06.02.2025.
//

enum OpenProduct {
    
    case card(OpenCard)
    case creditCardMVP
    case savingsAccount(SavingsAccountNodes)
    case unknown // TODO: replace with other types
    
    typealias OpenCard = Node<OpenCardDomain.Binder>
}
