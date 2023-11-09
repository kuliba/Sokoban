//
//  Services+getLandingService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.09.2023.
//

import Foundation
import GenericRemoteService
import LandingMapping
import LandingUIComponent
import CodableLanding

extension Services {
    
    typealias GetLanding = (serial: String, abroadType: AbroadType)    
    typealias GetLandingService = RemoteService<GetLanding, UILanding, Error, Error, Error>
    typealias Cache = (CodableLanding) -> Void
    
    static func getLandingService(
        httpClient: HTTPClient,
        withCache cache: @escaping Cache
    ) -> GetLandingService {
        
        let map: (Data, HTTPURLResponse) throws -> UILanding = { data, response in
            
            let mapperLanding = LandingMapper.map(data, response)
            
            let codableLanding = try? CodableLanding(mapperLanding.get())
            codableLanding.map(cache)
            
            return try .init(mapperLanding.get())
        }
        
        return .init(
            createRequest: RequestFactory.createLandingRequest,
            performRequest: httpClient.performRequest,
            mapResponse: map
        )
    }
}
