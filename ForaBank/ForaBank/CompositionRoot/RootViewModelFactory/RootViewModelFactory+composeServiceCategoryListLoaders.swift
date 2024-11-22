//
//  RootViewModelFactory+composeServiceCategoryListLoaders.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Foundation

extension RootViewModelFactory {
    
    typealias ServiceCategoryLoad = Load<[ServiceCategory]>
    
    /// Decorate with loading operators for category.
    @inlinable
    func composeDecoratedServiceCategoryListLoaders(
    ) -> (load: ServiceCategoryLoad, reload: ServiceCategoryLoad) {
        
        let operatorsService = servicePaymentOperatorService
        
        let (loadCategories, reloadCategories) = composeServiceCategoryListLoaders()
        
        let decorated = decorate(
            decoratee: reloadCategories,
            with: { categories, completion in
                
                let payloads = self.makeGetOperatorsListByParamPayloads(from: categories)
                
                operatorsService(payloads) { failed in
                    
                    completion(failed.map(\.category))
                    _ = operatorsService
                }
            }
        )
        
        // threading
        let load = schedulers.background.scheduled(loadCategories)
        let reload = schedulers.background.scheduled(decorated)
        
        return (load, reload)
    }
    
    private func composeServiceCategoryListLoaders(
    ) -> (load: ServiceCategoryLoad, reload: ServiceCategoryLoad) {
        
        let remoteLoad = nanoServiceComposer.composeServiceCategoryRemoteLoad()
        
        let (load, reload) = composeLoaders(
            remoteLoad: remoteLoad,
            fromModel: { $0.serviceCategory },
            toModel: { $0.codable }
        )
        
        return (load, reload)
    }
}
