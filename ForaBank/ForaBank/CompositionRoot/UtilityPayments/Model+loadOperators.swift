//
//  Model+loadOperators.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.02.2024.
//

import Foundation
import OperatorsListComponents

extension Model {
    
    typealias Payload = LoadOperatorsPayload<String>
    typealias LoadOperatorsResult = Result<[UtilityPaymentOperator<String>], Error>
    typealias LoadOperatorsCompletion = (LoadOperatorsResult) -> Void
    
    func loadOperators(
        _ payload: Payload,
        _ completion: @escaping LoadOperatorsCompletion
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            guard let self else { return }
            
            guard let operatorGroups = localAgent.load(type: [_OperatorGroup].self)
            else {
                completion(.failure(LoadOperatorsFailure()))
                return
            }
            
//            switch payload.id {
//            case .none:
//                let operators = operatorGroups
//                    .prefix(payload.pageSize)
//                    .map(OperatorsListComponents.Operator.init)
//                completion(.success(operators))
//                
//            case let .some(id):
//                let operators = operatorGroups
//                    .page(startingAt: id, pageSize: payload.pageSize)
//                    .map(OperatorsListComponents.Operator.init)
//                completion(.success(operators))
//            }
        }
    }
    
    struct LoadOperatorsFailure: Error {}
}

private extension UtilityPaymentOperator<String> {
    
    init(_ operatorGroup: OperatorGroup) {
        
        self.init(
            id: operatorGroup.title,
            title: operatorGroup.title,
            subtitle: operatorGroup.description,
            icon: operatorGroup.title
        )
    }
}
