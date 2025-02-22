//
//  RootViewModelFactory+makeOperationDetailModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import RemoteServices
import RxViewModel
import ProductSelectComponent

extension RootViewModelFactory {
    
    typealias LoadOperationDetailCompletion = (Result<OperationDetailDomain.ExtendedDetails, Error>) -> Void
    typealias LoadOperationDetail = (OperationDetailDomain.EnhancedPayload, @escaping LoadOperationDetailCompletion) -> Void
    
    @inlinable
    func makeOperationDetailModel(
        initialState: OperationDetailDomain.State,
        load: @escaping LoadOperationDetail
    ) -> OperationDetailDomain.Model {
        
        let reducer = OperationDetailDomain.Reducer()
        let effectHandler = OperationDetailDomain.EffectHandler { completion in
            
            load(initialState.payload, completion)
        }
        
        return .init(
            initialState: initialState,
            reduce: { state, event in
                
                var state = state
                let (details, effect) = reducer.reduce(state.extendedDetails, event)
                state.extendedDetails = details
                
                return (state, effect)
            },
            handleEffect: effectHandler.handleEffect,
            scheduler: schedulers.main
        )
    }
}

// MARK: - Adapters

private extension OperationDetailDomain.State {
    
    var payload: OperationDetailDomain.EnhancedPayload {
        
        return .init(
            formattedAmount: basicDetails.formattedAmount,
            paymentOperationDetailID: basicDetails.paymentOperationDetailID,
            product: basicDetails.product,
            status: basicDetails.status
        )
    }
}

extension OperationDetailDomain {
    
    struct EnhancedPayload: Equatable {
        
        let formattedAmount: String?
        let paymentOperationDetailID: Int
        let product: ProductSelect.Product
        let status: OperationDetailDomain.Status
    }
}
