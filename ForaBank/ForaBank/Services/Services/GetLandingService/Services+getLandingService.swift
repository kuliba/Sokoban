//
//  Services+getLandingService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.09.2023.
//

import Foundation
import GenericRemoteService
import LandingMapping

extension Services {
    
    typealias GetLandingService = RemoteService<Void, Landing>
    
    static func getLandingService(
        httpClient: HTTPClient
    ) -> GetLandingService {
        
        .init(
            createRequest: RequestFactory.createLandingRequest,
            performRequest: httpClient.performRequest,
            mapResponse: LandingMapper.map
        )
    }
}

// MARK: - Adapter

private extension LandingMapper {
    
    static func map(
        data: Data,
        response: HTTPURLResponse
    ) throws -> Landing {
        
        try map(data, response).get()
    }
}
