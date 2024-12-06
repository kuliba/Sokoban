//
//  LoggingRemoteNanoServiceComposer+composeServiceCategoryRemoteLoad.swift
//  Vortex
//
//  Created by Igor Malyarov on 19.10.2024.
//

import RemoteServices
import SerialComponents

extension LoggingRemoteNanoServiceComposer {
    
#warning("extract to a generic namespace")
    typealias ServiceCategoryListLoaderComposer = SerialComponents.SerialLoaderComposer<String, ServiceCategory, CodableServiceCategory>
    typealias ServiceCategoryListRemoteLoad = ServiceCategoryListLoaderComposer.RemoteLoad
    
    func composeServiceCategoryRemoteLoad() -> ServiceCategoryListRemoteLoad {
        
        composeSerialResultLoad(
            createRequest: RequestFactory.createGetServiceCategoryListRequest,
            mapResponse: ForaBank.ResponseMapper.mapGetServiceCategoryListResponse
        )
    }
}
