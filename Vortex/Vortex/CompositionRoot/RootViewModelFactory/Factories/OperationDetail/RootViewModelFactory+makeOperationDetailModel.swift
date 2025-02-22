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
    typealias LoadOperationDetail = (OperationDetailDomain.BasicDetails, @escaping LoadOperationDetailCompletion) -> Void
    
    @inlinable
    func makeOperationDetailModel(
        basicDetails: OperationDetailDomain.BasicDetails,
        load: @escaping LoadOperationDetail
    ) -> OperationDetailDomain.Model {
        
        let reducer = OperationDetailDomain.Reducer()
        let effectHandler = OperationDetailDomain.EffectHandler { completion in
            
            load(basicDetails, completion)
        }
        
        return .init(
            initialState: .init(
                basicDetails: basicDetails,
                extendedDetails: .pending
            ),
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
