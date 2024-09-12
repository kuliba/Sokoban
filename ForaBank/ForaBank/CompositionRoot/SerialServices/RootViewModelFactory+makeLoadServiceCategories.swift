//
//  RootViewModelFactory+makeLoadServiceCategories.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.09.2024.
//

import ForaTools
import RemoteServices

extension RootViewModelFactory {
    
    typealias _LoadServiceCategories = Load<[ServiceCategory]>
    
    static func makeLoadServiceCategories(
        getSerial: @escaping () -> String?,
        localComposer: LocalLoaderComposer,
        nanoServiceComposer: LoggingRemoteNanoServiceComposer
    ) -> (local: _LoadServiceCategories, remote: _LoadServiceCategories) {
        
        let localLoad = localComposer.composeLoad(
            fromModel: [ServiceCategory].init(codable:)
        )
        let save = localComposer.composeSave(
            toModel: [CodableServiceCategory].init(categories:)
        )
        
        let serviceCategoriesRemoteLoad = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetServiceCategoryListRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetServiceCategoryListResponse
        )
        let serviceCategoriesRemoteDecorator = SerialStampedCachingDecorator(
            decoratee: serviceCategoriesRemoteLoad,
            save: save
        )
        let fallback = SerialFallback(
            getSerial: getSerial,
            primary: serviceCategoriesRemoteDecorator.decorated,
            secondary: localLoad
        )
        
        return (localLoad, fallback.callAsFunction(completion:))
    }
}
