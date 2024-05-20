//
//  ViewModel+Preview.swift
//  OperatorsListPreview
//
//  Created by Дмитрий Савушкин on 20.02.2024.
//

import Foundation
import RxViewModel
import PrePaymentPicker
import OperatorsListComponents

typealias PrePaymentOptionsViewModel = RxViewModel<PrePaymentOptionsState<LastPayment, Operator>, PrePaymentOptionsEvent<LastPayment, Operator>, PrePaymentOptionsEffect<Operator>>

extension PrePaymentOptionsViewModel {

    static func preview(
        initialState: PrePaymentOptionsState<LastPayment, Operator>,
        observeLast: Int = 1,
        pageSize: Int = 20
    ) -> PrePaymentOptionsViewModel {
 
        let reducer = PrePaymentOptionsReducer<LastPayment, Operator>(
            observeLast: observeLast,
            pageSize: pageSize
        )

        let operatorsLoader = StubbedOperatorLoader()
        let effectHandler = PrePaymentOptionsEffectHandler<LastPayment, Operator>(
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

extension PrePaymentOptionsState {
    
    var filteredOperators: [OperatorsListComponents.Operator] {
        
        guard let operators = operators as? [OperatorsListComponents.Operator] else {
            return []
        }
        
        if searchText.isEmpty {
            return operators
            
        } else {
            
            return operators.filter { item in
                
                item.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

extension StubbedOperatorLoader {
    
    typealias UPRxPayload = PrePaymentOptionsEffectHandler<LastPayment, Operator>.LoadOperatorsPayload
    typealias UPRxCompletion = PrePaymentOptionsEffectHandler<LastPayment, Operator>.LoadOperatorsCompletion
    
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

private extension PrePaymentPicker.ServiceFailure {

    init(_ error: ServiceFailure) {
        
        switch error {
        case .connectivityError:
            self = .connectivityError
            
        case let .serverError(string):
            self = .serverError(string)
        }
    }
}
