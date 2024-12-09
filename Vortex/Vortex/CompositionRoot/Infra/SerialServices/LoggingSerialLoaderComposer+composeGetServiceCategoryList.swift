//
//  LoggingSerialLoaderComposer+composeGetServiceCategoryList.swift
//  Vortex
//
//  Created by Igor Malyarov on 16.10.2024.
//

import VortexTools
import Foundation
import RemoteServices
import SerialComponents

extension LoggingSerialLoaderComposer {
    
    func composeGetServiceCategoryList(
    ) -> (load: Load<ServiceCategory>, reload: Load<ServiceCategory>) {
        
        return compose(
            createRequest: RequestFactory.createGetServiceCategoryListRequest,
            mapResponse: Vortex.ResponseMapper.mapGetServiceCategoryListResponse,
            fromModel: { $0.serviceCategory },
            toModel: { $0.codable }
        )
    }
}

// MARK: - Adapters

/*private*/ extension Vortex.ResponseMapper {
    
    static func mapGetServiceCategoryListResponse(
        data: Data,
        response: HTTPURLResponse
    ) -> Result<SerialComponents.SerialStamped<String, [ServiceCategory]>, Error> {
        
        RemoteServices.ResponseMapper
            .mapGetServiceCategoryListResponse(data, response)
            .map { .init(value: $0.list, serial: $0.serial) }
            .mapError { $0 }
    }
}
