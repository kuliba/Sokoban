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
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> CreateSberQRPayment {
        
        let createSberQRPaymentService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createCreateSberQRPaymentRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: SberQR.ResponseMapper.mapCreateSberQRPaymentResponse,
            log: log
        ).remoteService
        
        return createSberQRPaymentService.process(_:completion:)
    }
}
