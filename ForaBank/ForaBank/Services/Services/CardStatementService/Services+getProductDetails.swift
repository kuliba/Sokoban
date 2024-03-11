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
    
    static func getProductDetails(
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
