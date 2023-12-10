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
    
    typealias CreateSberQRPaymentService = MappingRemoteService<CreateSberQRPaymentPayload, CreateSberQRPaymentResponse, MappingError>
    
    static func makeCreateSberQRPaymentService(
        httpClient: HTTPClient
    ) -> CreateSberQRPaymentService {
        
        .init(
            createRequest: RequestFactory.createCreateSberQRPaymentRequest,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: SberQR.ResponseMapper.mapCreateSberQRPaymentResponse
        )
    }
}
