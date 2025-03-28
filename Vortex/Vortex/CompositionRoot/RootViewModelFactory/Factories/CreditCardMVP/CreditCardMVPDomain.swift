//
//  CreditCardMVPDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import CreditCardMVPUI
import FlowCore
import Foundation
import PaymentCompletionUI
import RxViewModel

typealias CreditCardMVPDomain = GenericCreditCardMVPDomain<Void>

/// A namespace.
enum GenericCreditCardMVPDomain<T> {}

extension GenericCreditCardMVPDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = T
    
    // MARK: - Flow
    
    typealias Flow = CreditCardMVPFlowDomain.Flow
    typealias Notify = CreditCardMVPFlowDomain.Notify
    
    typealias Select = CreditCardMVPFlowDomain.Select
    typealias Navigation = CreditCardMVPFlowDomain.Navigation
}

/// A namespace.
enum CreditCardMVPFlowDomain {}

extension CreditCardMVPFlowDomain {
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
        
        case alert(String)
        case approved(consent: AttributedString, ProductCard)
        case failure
        case informer(String)
        case inReview
        case rejected
    }
    
    enum Navigation {
        
        case alert(String)
        case complete(Complete)
        case decision(Decision)
        case informer(String)
        
        struct Complete: Equatable {
            
            let message: String
            let status: Status
            
            enum Status {
                
                case failure, inReview
            }
        }
        
        struct Decision: Equatable {
            
            let message: String
            let status: Status
            let title: String
            
            enum Status: Equatable {
                
                case approved(Approved)
                case rejected
                
                struct Approved: Equatable {
                    
                    let consent: AttributedString
                    let info: String
                    let product: ProductCard
                }
            }
        }
    }
}
