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

typealias UtilityPaymentsViewModel = RxViewModel<UtilityPaymentsState, UtilityPaymentsEvent, UtilityPaymentsEffect>

extension UtilityPaymentsViewModel {

    static func preview(
        initialState: UtilityPaymentsState,
        observeLast: Int = 3,
        pageSize: Int = 10
    ) -> UtilityPaymentsViewModel {
 
        let reducer = UtilityPaymentsReducer(
            observeLast: observeLast,
            pageSize: pageSize
        )

        let operatorsLoader = StubbedOperatorLoader()
        let effectHandler = UtilityPaymentsEffectHandler(
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
    
    typealias UPRxPayload = UtilityPaymentsEffectHandler.LoadOperatorsPayload
    typealias UPRxCompletion = UtilityPaymentsEffectHandler.LoadOperatorsCompletion
    
    func load(
        _ payload: UPRxPayload?,
        _ completion: @escaping UPRxCompletion
    ) {
        
        let payload: Payload? = payload.map { ($0.0.rawValue, $0.1) }
        
        load(payload) { result in
            
            switch result {
            case let .success(operators):
                let ops = operators.map(UtilityPaymentsRx.Operator.init)
                completion(.success(ops))
                
            case let .failure(error):
                completion(.failure(.init(error)))
            }
        }
    }
}

private extension Array where Element == UtilityPaymentsRx.LastPayment {

    static let preview = [LatestPayment].preview.map { latestPayment in
            Element.init(id: .init(latestPayment.id))
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

private extension UtilityPaymentsRx.Operator {
    
    init(_ operator: OperatorsListComponents.Operator) {
        
        self.init(id: .init(`operator`.id))
    }
}
