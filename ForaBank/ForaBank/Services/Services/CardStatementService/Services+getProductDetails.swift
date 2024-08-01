//
//  Services+getProductDetails.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Foundation
import GenericRemoteService
import AccountInfoPanel

extension Services {
    
    typealias GetProductDetailsPayload = ProductDetailsPayload
    typealias GetProductDetailsService = MappingRemoteService<GetProductDetailsPayload, ProductDetails, GetProductDetailsMappingError>
    
    static func makeGetProductDetails(
        httpClient: HTTPClient,
        logger: LoggerAgentProtocol,
        payload: GetProductDetailsPayload
    ) async throws -> ProductDetails {
        
        let networkLog = { logger.log(level: $0, category: .network, message: $1, file: $2, line: $3) }
     
        let data = try await getProductDetails(
            httpClient: httpClient,
            log: { networkLog(.info, $0, $1, $2) }
        ).process(payload)
        
        return data
    }
    
    private static func getProductDetails(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> GetProductDetailsService {
        
        LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createGetProductDetailsRequest(payload:),
            performRequest: httpClient.performRequest,
            mapResponse: GetProductDetailsResponseMapper.mapGetProductDetailsResponse,
            log: log
        ).remoteService
    }
}
