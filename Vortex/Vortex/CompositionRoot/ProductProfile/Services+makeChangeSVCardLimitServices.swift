//
//  Services+makeChangeSVCardLimitServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 08.07.2024.
//

import Foundation
import GenericRemoteService
import RemoteServices

extension Services {
    
    static func makeChangeSVCardLimitServices(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> ChangeSVCardLimitServices {
        
        let createChangeSVCardLimitService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createChangeSVCardLimitRequest(payload:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: RemoteServices.ResponseMapper.mapChangeSVCardLimitResponse,
            log: log
        ).remoteService
        
        let createGetSVCardLimitsService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createGetSVCardLimitsRequest(payload:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: RemoteServices.ResponseMapper.mapGetSVCardLimitsResponse,
            log: log
        ).remoteService

        
        return .init(
            createChangeSVCardLimit: createChangeSVCardLimitService.process(_:completion:),
            createGetSVCardLimits: createGetSVCardLimitsService.process(_:completion:)
        )
    }
}
