//
//  Services+makeSVCardLandingServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 09.07.2024.
//

import Foundation
import GenericRemoteService
import RemoteServices
import LandingUIComponent
import LandingMapping

extension Services {
    
    static func makeSVCardLandingServices(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> SVCardLandingServices {
        
        let createSVCardlaningService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createLandingRequest(_:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: LandingMapper.map,
            log: log
        ).remoteService
        
        return .init(
            createSVCardLanding: createSVCardlaningService.process(_:completion:)
        )
    }
}
