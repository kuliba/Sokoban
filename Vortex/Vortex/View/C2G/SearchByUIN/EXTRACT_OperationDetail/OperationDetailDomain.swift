//
//  OperationDetailDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import StateMachines
import RxViewModel

enum OperationDetailDomain {}

extension OperationDetailDomain {
    
    typealias Model = RxViewModel<State, Event, Effect>
    
    typealias Reducer = StateMachines.LoadReducer<State.Details, Error>
    typealias EffectHandler = StateMachines.LoadEffectHandler<State.Details, Error>
    
    typealias Event = StateMachines.LoadEvent<State.Details, Error>
    typealias Effect = StateMachines.LoadEffect
    
    struct State {
        
        var details: StateMachines.LoadState<Details, Error>
        let response: EnhancedResponse
        
        typealias Details = Int // TODO: replace with operation details
        
        struct EnhancedResponse: Equatable {
            
            let formattedAmount: String?
            let merchantName: String?
            let message: String?
            let paymentOperationDetailID: Int
            let product: ProductData // too much
            let purpose: String?
            let status: Status
            let uin: String
            
            enum Status {
                
                case completed, inflight, rejected
            }
        }
    }
}
