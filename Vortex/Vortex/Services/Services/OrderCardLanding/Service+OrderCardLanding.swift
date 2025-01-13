//
//  Service+OrderCardLanding.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import Foundation
import GenericRemoteService
import OrderCardLandingBackend

extension Services {
    
    typealias OrderCardLandingResponse = OrderCardLandingBackend.OrderCardLandingResponse
    
    typealias OrderCardLandingResponseCompletion = (OrderCardLandingResponse) -> Void
    typealias OrderCardLanding = (@escaping OrderCardLandingResponseCompletion) -> Void

    static func getOrderCardLanding(
        _ httpClient: HTTPClient,
        _ timeout: TimeInterval = 120.0,
        logger: LoggerAgentProtocol
    ) -> OrderCardLanding {
        
        let infoNetworkLog = { logger.log(level: .info, category: .network, message: $0, file: $1, line: $2) }

        let loggingRemoteService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createGetDigitalCardLandingRequest,
            performRequest: httpClient.performRequest,
            mapResponse: OrderCardLandingBackend.ResponseMapper.mapOrderCardLandingResponse,
            log: infoNetworkLog
        ).remoteService
        
        return { completion in
            
            loggingRemoteService.process(()) { result in
                
                if let landing = try? result.get() {
                    completion(landing)
                    _ = loggingRemoteService

                } else {
                    _ = loggingRemoteService
                }
            }
        }
    }
}
