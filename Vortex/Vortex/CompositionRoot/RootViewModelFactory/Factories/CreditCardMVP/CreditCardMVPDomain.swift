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

/// A namespace.
enum CreditCardMVPDomain {}

extension CreditCardMVPDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = Void
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
        
        case alert(String)
        case failure
        case informer(String)
        case approved(consent: AttributedString, ProductCard)
        case inReview
        case rejected(ProductCard)
    }
    
    enum Navigation {
        
        case alert(String)
        case informer(String)
        case complete(Complete)
        case decision(Decision)
        
        struct Complete: Equatable {
            
            let message: String
            let status: Status
            
            enum Status {
                
                case failure, inReview
            }
        }
        
        struct Decision: Equatable {
            
            let message: String
            let product: ProductCard
            let title: String
            let status: Status
            
            enum Status: Equatable {
                
                case approved(Details)
                case rejected
                
                struct Details: Equatable {
                    
                    let consent: AttributedString
                    let info: String
                }
            }
        }
    }
}
