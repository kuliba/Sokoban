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
        
        let serviceCategoriesRemoteLoad = nanoServiceComposer.compose(
            createRequest: RequestFactory.createGetServiceCategoryListRequest,
            mapResponse: RemoteServices.ResponseMapper.mapGetServiceCategoryListResponse
        )
        let serviceCategoriesRemoteDecorator = SerialStampedCachingDecorator(
            decoratee: serviceCategoriesRemoteLoad,
            save: localComposer.composeSave(
                toModel: [CodableServiceCategory].init(categories:)
            )
        )
        let serviceCategoriesCachingRemoteLoad = { completion in
            
            serviceCategoriesRemoteDecorator.decorated(getSerial(), completion: completion)
        }
        
        let remoteLoad: _LoadServiceCategories = { completion in
            
            serviceCategoriesCachingRemoteLoad {
                
                completion(try? $0.map(\.value).get())
            }
        }
        
        return (localLoad, remoteLoad)
    }
}
