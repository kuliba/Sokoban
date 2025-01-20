//
//  RootViewModelFactory+composeDecoratedServiceCategoryListLoaders.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Foundation

extension RootViewModelFactory {
    
    typealias ServiceCategoryLoad = Load<[ServiceCategory]>
    
    /// Compose `ServiceCategory` Loaders decorated with `operatorsService` (operators loading and caching).
    @inlinable
    func composeDecoratedServiceCategoryListLoaders(
    ) -> (load: ServiceCategoryLoad, reload: ServiceCategoryLoad) {
        
        let (loadCategories, reloadCategories) = composeServiceCategoryListLoaders()
        
        let decorated = decorate(reloadCategories, with: batchOperators)
        
        // threading
        let load = schedulers.userInitiated.scheduled(loadCategories)
        let reload = schedulers.userInitiated.scheduled(decorated)
        
        return (load, reload)
    }
    
    @inlinable
    func batchOperators(
        categories: [ServiceCategory],
        completion: @escaping ([ServiceCategory]) -> Void
    ) {
        let payloads = makeGetOperatorsListByParamPayloads(from: categories)
        
        servicePaymentOperatorService(payloads: payloads) { failed in
            
            completion(failed.map(\.category))
        }
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
