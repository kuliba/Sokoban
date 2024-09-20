//
//  StandardSelectedCategoryDestinationNanoServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import PayHub

final class StandardSelectedCategoryDestinationNanoServicesComposer {
    
    private let loadLatest: LoadLatest
    private let loadOperators: LoadOperators
    
    init(
        loadLatest: @escaping LoadLatest,
        loadOperators: @escaping LoadOperators
    ) {
        self.loadLatest = loadLatest
        self.loadOperators = loadOperators
    }
    
    typealias LoadLatest = (ServiceCategory, @escaping (Result<[Latest], Error>) -> Void) -> Void

    typealias Operator = PaymentServiceOperator
    typealias LoadOperators = (ServiceCategory, @escaping (Result<[Operator], Error>) -> Void) -> Void
}

extension StandardSelectedCategoryDestinationNanoServicesComposer {
    
    func compose(
        category: ServiceCategory
    ) -> StandardNanoServices {
        
        let loadLatest = { self.loadLatest(category, $0) }
        let loadOperators = { self.loadOperators(category, $0) }
        
        return .init(
            loadLatest: loadLatest,
            loadOperators: loadOperators,
            makeFailure: { $0(.init()) },
            makeSuccess: { payload, completion in
                
                completion(.init(
                    category: category,
                    latest: payload.latest,
                    operators: payload.operators
                ))
            }
        )
    }
    
    typealias StandardNanoServices = StandardSelectedCategoryDestinationNanoServices<ServiceCategory, Latest, Operator, SelectedCategoryStub, FailedPaymentProviderPickerStub>
}
