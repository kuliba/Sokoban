//
//  Services+makeGetSavingsAccountInfoServices.swift
//  Vortex
//
//  Created by Andryusina Nataly on 25.02.2025.
//

import Foundation
import GenericRemoteService
import RemoteServices

extension Services {
    
    static func makeGetSavingsAccountInfoServices(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> GetSavingsAccountInfoServices {
        
        let createService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createGetSavingsAccountInfoRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: RemoteServices.ResponseMapper.mapGetSavingsAccountInfoResponse,
            log: log
        ).remoteService
        
        return .init(
            createGetSavingsAccountInfo: createService.process(_:completion:)
        )
    }
}
