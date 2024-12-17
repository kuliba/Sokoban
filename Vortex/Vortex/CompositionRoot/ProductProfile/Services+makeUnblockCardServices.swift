//
//  Services+makeUnblockCardServices.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 07.05.2024.
//

import Foundation
import GenericRemoteService
import RemoteServices

extension Services {
    
    static func makeUnblockCardServices(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> UnblockCardServices {
        
        let createUnblockCardService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createUnblockCardRequest(payload:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: RemoteServices.ResponseMapper.mapUnblockCardResponse,
            log: log
        ).remoteService
        
        return .init(
            createUnblockCard: createUnblockCardService.process(_:completion:)
        )
    }
}
