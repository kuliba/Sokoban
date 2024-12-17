//
//  Services+makeGetSVCardLimitsServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 05.07.2024.
//

import Foundation
import GenericRemoteService
import RemoteServices

extension Services {
    
    static func makeGetSVCardLimitsServices(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> GetSVCardLimitsServices {
        
        let createGetSVCardLimitsService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createGetSVCardLimitsRequest(payload:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: RemoteServices.ResponseMapper.mapGetSVCardLimitsResponse,
            log: log
        ).remoteService
        
        return .init(
            createGetSVCardLimits: createGetSVCardLimitsService.process(_:completion:)
        )
    }
}
