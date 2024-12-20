//
//  Service+modifyC2B.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 11.11.2024.
//

import Foundation
import RemoteServices
import ModifyC2BSubscriptionService

extension Services {
    
    typealias ModifyC2BSubscriptionPayload = ModifyC2BSubscription
    typealias ModifyC2BSubscriptionServiceData = MappingRemoteService<ModifyC2BSubscription, ModifyC2BSubscriptionService.C2BSubscriptionData, RemoteServices.ResponseMapper.MappingError>
    
    static func makeModifyC2B(
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        payload: ModifyC2BSubscriptionPayload
    ) async throws -> ModifyC2BSubscriptionService.C2BSubscriptionData {
        
        let networkLog = { logger.log(level: $0, category: .network, message: $1, file: $2, line: $3) }
     
        let data = try await modifyC2BData(
            payload,
            httpClient: httpClient,
            log: { networkLog(.info, $0, $1, $2) }
        ).process(payload) 
        
        return data
    }
    
    private static func modifyC2BData(
        _ modifyC2BSubscription: ModifyC2BSubscription,
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> ModifyC2BSubscriptionServiceData {
        
        LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.modifyC2BDataRequest,
            performRequest: httpClient.performRequest,
            mapResponse: RemoteServices.ResponseMapper.mapModifyC2BSubscriptionResponse,
            log: log
        ).remoteService
    }
}
