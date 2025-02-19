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
    
    typealias Content = C2GPaymentViewModel<Context>
    typealias ContentReducer = C2GPaymentReducer<Context>
    
    struct Context: Equatable {
        
        let term: AttributedString
    }
    
    struct ContentPayload: Equatable {
        
        let selectedProduct: ProductSelect.Product
        let products: [ProductSelect.Product]
        let termsCheck: Bool?
        let uin: String
        let url: URL?
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
        case success(C2GPaymentComplete)
        
        struct C2GPaymentComplete: Equatable {
            
            let formattedAmount: String?
            let status: Status
            let merchantName: String?
            let message: String?
            let paymentOperationDetailID: Int
            let purpose: String?
            
            enum Status {
                
                case completed, inflight, rejected
            }
        }
    }
}
