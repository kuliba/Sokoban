//
//  Model+loadOperators.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.02.2024.
//

import Foundation
import OperatorsListComponents

extension Model {
    
    typealias Payload = LoadOperatorsPayload
    typealias LoadOperatorsResult = Result<[OperatorsListComponents.Operator], Error>
    typealias LoadOperatorsCompletion = (LoadOperatorsResult) -> Void
    
    func loadOperators(
        _ payload: Payload,
        _ completion: @escaping LoadOperatorsCompletion
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            guard let self else { return }
            
            if let operators = localAgent.load(type: [_OperatorGroup].self) {
                
                completion(.success(
                    operators
                        .paged(with: payload)
                        .map(OperatorsListComponents.Operator.init)
                ))
            } else {
                
                completion(.failure(LoadOperatorsFailure()))
            }
        }
    }
    
    struct LoadOperatorsFailure: Error {}
}
