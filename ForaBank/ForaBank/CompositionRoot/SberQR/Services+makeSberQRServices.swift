//
//  Services+makeSberQRServices.swift
//  Vortex
//
//  Created by Igor Malyarov on 09.12.2023.
//

import Foundation
import GenericRemoteService
import SberQR

extension Services {
    
    static func makeSberQRServices(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> SberQRServices {
        
        let createSberQRPaymentService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createCreateSberQRPaymentRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: SberQR.ResponseMapper.mapCreateSberQRPaymentResponse,
            log: log
        ).remoteService
        
        let getSberQRDataService = LoggingRemoteServiceDecorator(
            createRequest: RequestFactory.createGetSberQRRequest(_:),
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: SberQR.ResponseMapper.mapGetSberQRDataResponse,
            log: log
        ).remoteService

        return .init(
            createSberQRPayment: createSberQRPaymentService.process(_:completion:),
            getSberQRData: getSberQRDataService.process(_:completion:)
        )
    }
}
