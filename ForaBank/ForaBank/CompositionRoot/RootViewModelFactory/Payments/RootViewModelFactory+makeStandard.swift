//
//  RootViewModelFactory+makeStandard.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import Foundation
import PayHub

extension RootViewModelFactory {
    
    func makeStandard(
        _ category: ServiceCategory,
        completion: @escaping (StandardSelectedCategoryDestination) -> Void
    ) {
        let getLatestPayments = nanoServiceComposer.composeGetLatestPayments()
        let microServicesComposer = UtilityPrepaymentMicroServicesComposer(
            pageSize: settings.pageSize,
            nanoServices: .init(loadOperators: loadOperators)
        )
        let standardNanoServicesComposer = StandardSelectedCategoryDestinationNanoServicesComposer(
            loadLatest: { getLatestPayments([$0.name], $1) },
            loadOperators: loadOperatorsForCategory,
            makeMicroServices: microServicesComposer.compose,
            model: self.model,
            scheduler: schedulers.main
        )
        let standardNanoServices = standardNanoServicesComposer.compose(category: category)
        let composer = StandardSelectedCategoryDestinationMicroServiceComposer(
            nanoServices: standardNanoServices
        )
        let standardMicroService = composer.compose()
        
        standardMicroService.makeDestination(category) {
            
            completion($0)
            _ = standardMicroService
        }
    }
}
