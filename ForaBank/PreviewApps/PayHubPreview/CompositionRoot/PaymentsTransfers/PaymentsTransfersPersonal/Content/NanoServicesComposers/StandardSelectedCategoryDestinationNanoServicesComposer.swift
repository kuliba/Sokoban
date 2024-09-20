//
//  StandardSelectedCategoryDestinationNanoServicesComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 03.09.2024.
//

import Foundation
import PayHub

final class StandardSelectedCategoryDestinationNanoServicesComposer {}

extension StandardSelectedCategoryDestinationNanoServicesComposer {
    
    func compose(category: ServiceCategory) -> NanoServices {
        
        let loadLatest = { completion in self.loadLatest(category, completion) }
        let loadOperators = { completion in self.loadOperators(category, completion) }
        
        return .init(
            loadLatest: loadLatest,
            loadOperators: loadOperators,
            makeFailure: { $0(NSError(domain: "Failure", code: -1)) },
            makeSuccess: { payload, completion in
                
                completion(.init(
                    category: category,
                    latest: payload.latest,
                    operators: payload.operators
                ))
            }
        )
    }
    
    typealias NanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, Operator, SelectedCategoryStub, Error>
}

private extension StandardSelectedCategoryDestinationNanoServicesComposer {
    
    func loadLatest(
        _ category: ServiceCategory,
        _ completion: @escaping (Result<[Latest], Error>) -> Void
    ) {
        if category.paymentFlowID == .mobile {
            completion(.success([.init(id: UUID().uuidString)]))
        } else {
            completion(.success([]))
        }
    }
    
    func loadOperators(
        _ category: ServiceCategory,
        _ completion: @escaping (Result<[Operator], Error>) -> Void
    ) {
        if category.name == "Failure" {
            completion(.success([]))
        } else {
            completion(.success([.init(), .init()]))
        }
    }
}
