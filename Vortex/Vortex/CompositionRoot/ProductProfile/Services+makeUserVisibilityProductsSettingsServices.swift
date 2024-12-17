//
//  Services+makeUserVisibilityProductsSettingsServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 05.07.2024.
//

import Foundation
import GenericRemoteService
import RemoteServices

extension Services {
    
    static func makeUserVisibilityProductsSettingsServices(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> UserVisibilityProductsSettingsServices {
        
        let createUserVisibilityProductsSettingsService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createUserVisibilityProductsSettingsRequest(payload:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: RemoteServices.ResponseMapper.mapToVoid,
            log: log
        ).remoteService
        
        return .init(
            createUserVisibilityProductsSettings: createUserVisibilityProductsSettingsService.process(_:completion:)
        )
    }
}
