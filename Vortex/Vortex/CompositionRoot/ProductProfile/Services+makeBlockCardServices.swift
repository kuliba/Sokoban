//
//  Services+makeBlockCardServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 28.06.2024.
//

import Foundation
import GenericRemoteService
import RemoteServices

extension Services {
    
    static func makeBlockCardServices(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> BlockCardServices {
        
        let createBlockCardService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createBlockCardRequest(payload:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: RemoteServices.ResponseMapper.mapBlockCardResponse,
            log: log
        ).remoteService
        
        return .init(
            createBlockCard: createBlockCardService.process(_:completion:)
        )
    }
}
