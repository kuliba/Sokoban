//
//  ViewModel+Preview.swift
//  OperatorsListPreview
//
//  Created by Дмитрий Савушкин on 20.02.2024.
//

import Foundation
import RxViewModel
import UtilityPaymentsRx
import OperatorsListComponents

typealias UtilityPaymentsViewModel = RxViewModel<UtilityPaymentsState<LatestPayment, Operator>, UtilityPaymentsEvent<LatestPayment, Operator>, UtilityPaymentsEffect<Operator>>

extension UtilityPaymentsViewModel {

    static func preview(
        initialState: UtilityPaymentsState<LatestPayment, Operator>,
        observeLast: Int = 1,
        pageSize: Int = 20
    ) -> UtilityPaymentsViewModel {
 
        let reducer = UtilityPaymentsReducer<LatestPayment, Operator>(
            observeLast: observeLast,
            pageSize: pageSize
        )

        let operatorsLoader = StubbedOperatorLoader()
        let effectHandler = UtilityPaymentsEffectHandler<LatestPayment, Operator>(
            loadLastPayments: { $0(.success(.preview)) },
            loadOperators: operatorsLoader.load,
            scheduler: .immediate
        )

        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}

extension StubbedOperatorLoader {
    
    typealias UPRxPayload = UtilityPaymentsEffectHandler<LatestPayment, Operator>.LoadOperatorsPayload
    typealias UPRxCompletion = UtilityPaymentsEffectHandler<LatestPayment, Operator>.LoadOperatorsCompletion
    
    func load(
        _ payload: UPRxPayload?,
        _ completion: @escaping UPRxCompletion
    ) {
        
        let payload: Payload? = payload.map { ($0.0.description, $0.1) }
        
        load(payload) { result in
            
            switch result {
            case let .success(operators):
                completion(.success(operators))
                
            case let .failure(error):
                completion(.failure(.init(error)))
            }
        }
    }
}

private extension UtilityPaymentsRx.ServiceFailure {

    init(_ error: ServiceFailure) {
        
        switch error {
        case .connectivityError:
            self = .connectivityError
            
        case let .serverError(string):
            self = .serverError(string)
        }
    }
}
