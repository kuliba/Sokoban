//
//  Services+makeCreateSberQRPaymentService.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2023.
//

import Foundation
import GenericRemoteService
import SberQR

extension Services {
    
    private typealias CreateSberQRPaymentService = MappingRemoteService<CreateSberQRPaymentPayload, CreateSberQRPaymentResponse, MappingError>
    
    static func makeCreateSberQRPayment(
        httpClient: HTTPClient
        // log: @escaping (LoggerAgentLevel, String, StaticString, UInt) -> Void
    ) -> CreateSberQRPayment {
        
        #warning("add logging")
        // LoggingRemoteServiceDecorator(
        let createSberQRPaymentService = CreateSberQRPaymentService(            createRequest: RequestFactory.createCreateSberQRPaymentRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: SberQR.ResponseMapper.mapCreateSberQRPaymentResponse
        )
        
        return createSberQRPaymentService.process(_:completion:)
    }
}
