//
//  RootViewModel+composeServiceCategoryListLoaders.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Foundation

extension RootViewModelFactory {
    
    typealias ServiceCategoryLoad = Load<[ServiceCategory]>
    
    func composeServiceCategoryListLoaders(
    ) -> (load: ServiceCategoryLoad, reload: ServiceCategoryLoad) {
        
        let serviceCategoryRemoteLoad = nanoServiceComposer.composeServiceCategoryRemoteLoad()
        let remoteLoad = /*backgroundScheduler.scheduled(*/serviceCategoryRemoteLoad//)
        
        let (serviceCategoryListLoad, serviceCategoryListReload) = composeLoaders(
            remoteLoad: remoteLoad,
            fromModel: { $0.serviceCategory },
            toModel: { $0.codable }
        )
        
        // threading
        let load = /*backgroundScheduler.scheduled(*/serviceCategoryListLoad//)
        let reload = /*backgroundScheduler.scheduled(*/serviceCategoryListReload//)
        
        return (load, reload)
    }
}
