//
//  C2GPaymentDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import C2GCore
import FlowCore
import Foundation
import PaymentComponents
import RxViewModel

typealias C2GPaymentViewModel<Context> = RxViewModel<C2GPaymentState<Context>, C2GPaymentEvent, C2GPaymentEffect>

/// A namespace.
enum C2GPaymentDomain {}

extension C2GPaymentDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = C2GPaymentViewModel<URL>
    typealias ContentReducer = C2GPaymentReducer<URL>
    
    struct ContentPayload: Equatable {
        
        let selectedProduct: ProductSelect.Product
        let products: [ProductSelect.Product]
        let termsCheck: Bool
        let uin: String
        let url: URL
    }
    
    // MARK: - Flow
    
    typealias FlowDomain = FlowCore.FlowDomain<Select, Navigation>
    typealias Flow = FlowDomain.Flow
    typealias Notify = FlowDomain.Notify
    
    enum Select: Equatable {
        
        case pay(Digest)
        
        typealias Digest = C2GCore.C2GPaymentDigest
    }
    
    enum Navigation {
        
        case failure(BackendFailure)
        case success(PaymentSuccess)
        
        typealias PaymentSuccess = Void
    }
}
