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

/// A namespace.
enum C2GPaymentDomain {}

extension C2GPaymentDomain {
    
    // MARK: - Binder
    
    typealias Binder = FlowCore.Binder<Content, Flow>
    
    // MARK: - Content
    
    typealias Content = RxViewModel<C2GPaymentState<Context>, C2GPaymentEvent, C2GPaymentEffect>
    typealias ContentReducer = C2GPaymentReducer<Context>
    
    struct Context: Equatable {
        
        let dateN: String?
        let discount: String?
        let discountExpiry: String?
        let formattedAmount: String? // transAmm
        let legalAct: String?
        let merchantName: String?
        let payerINN: String?
        let payerKPP: String?
        let payerName: String?
        let paymentTerm: String?
        let purpose: String?
        let term: AttributedString
        let uin: String
    }
    
    struct ContentPayload: Equatable {
        
        let dateN: String?
        let discount: String?
        let discountExpiry: String?
        let formattedAmount: String?
        let legalAct: String?
        let merchantName: String?
        let payerINN: String?
        let payerKPP: String?
        let payerName: String?
        let paymentTerm: String?
        let products: [ProductSelect.Product]
        let purpose: String?
        let selectedProduct: ProductSelect.Product
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
    
    typealias Navigation = Result<Complete, BackendFailure>
    
    struct Complete {
        
        let context: Context
        let details: OperationDetailDomain.Model
        let document: DocumentButtonDomain.Model
        
        struct Context: Equatable {
            
            let dateForDetail: String
            let formattedAmount: String?
            let merchantName: String?
            let purpose: String?
            let status: Status
            
            enum Status {
                
                case completed, inflight, rejected
            }
        }
    }
}
