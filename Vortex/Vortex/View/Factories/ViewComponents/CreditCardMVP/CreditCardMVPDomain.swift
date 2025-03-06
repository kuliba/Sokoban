//
//  CreditCardMVPDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 27.02.2025.
//

import FlowCore
import Foundation
import RxViewModel
import PaymentCompletionUI

/// A namespace.
enum CreditCardMVPDomain {}

extension CreditCardMVPDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = RxViewModel<State, Event, Effect>
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select {
        
        case order(OrderPayload)
        
        struct OrderPayload: Equatable {
            
            let otp: String
        }
    }
    
    enum Navigation {
        
        case complete(Complete)
        
        struct Complete: Identifiable {
            
            let id: UUID
            let message: String
            let status: PaymentCompletion.Status
            
            init(
                id: UUID = .init(),
                message: String,
                status: PaymentCompletion.Status
            ) {
                self.id = id
                self.message = message
                self.status = status
            }
        }
    }
}

extension CreditCardMVPDomain {
    
    struct State: Equatable {
        
        var otp: String
        
        var isValid: Bool { otp.count == 6 }
    }
    
    enum Event: Equatable {
        
        case otp(String)
    }
    
    enum Effect: Equatable {}
}
