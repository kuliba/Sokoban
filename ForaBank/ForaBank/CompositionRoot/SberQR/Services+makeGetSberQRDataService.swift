//
//  Services+makeGetSberQRDataService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation
import GenericRemoteService
import SberQR

extension Services {
    
    typealias GetSberQRDataService = MappingRemoteService<URL, GetSberQRDataResponse, GetSberQRDataError>
    
    static func makeGetSberQRDataService(
        httpClient: HTTPClient
        // log: @escaping (LoggerAgentLevel, String, StaticString, UInt) -> Void
    ) -> GetSberQRDataService {
        
        //LoggingRemoteServiceDecorator(
        .init(
            createRequest: RequestFactory.createGetSberQRRequest(_:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: SberQR.ResponseMapper.mapGetSberQRDataResponse
        )
    }
}
