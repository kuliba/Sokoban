//
//  RootViewModelFactory+makeOperationDetailModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.02.2025.
//

import RemoteServices
import StateMachines
import RxViewModel

extension RootViewModelFactory {
    
    @inlinable
    func makeOperationDetailModel(
        operationDetailID: Int
    ) -> OperationDetailDomain.Model {
        
        let load = onBackground(
            makeRequest: RequestFactory.createGetOperationDetailByPaymentIDRequestV3,
            mapResponse: RemoteServices.ResponseMapper.mapGetOperationDetailByPaymentIDResponse
        )
        
        let reducer = OperationDetailDomain.Reducer()
        let effectHandler = OperationDetailDomain.EffectHandler { completion in
            
            load(.init(operationDetailID)) {
                
                completion($0.map { _ in () })
            }
        }
        
        return .init(
            initialState: .pending,
            reduce: reducer.reduce,
            handleEffect: effectHandler.handleEffect,
            scheduler: schedulers.main
        )
    }
}

enum OperationDetailDomain {}

extension OperationDetailDomain {
    
    typealias Model = RxViewModel<State, Event, Effect>
    
    typealias Reducer = StateMachines.LoadReducer<Success, Error>
    typealias EffectHandler = StateMachines.LoadEffectHandler<Success, Error>
    
    typealias State = StateMachines.LoadState<Success, Error>
    typealias Event = StateMachines.LoadEvent<Success, Error>
    typealias Effect = StateMachines.LoadEffect
    
    typealias Success = Void
    typealias Failure = Error
}
