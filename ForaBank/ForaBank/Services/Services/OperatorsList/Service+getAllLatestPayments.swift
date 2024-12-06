//
//  Service+getAllLatestPayments.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 13.05.2024.
//

import Foundation
import GenericRemoteService
import OperatorsListComponents

extension Services {
    
    typealias GetAllPaymentsResult = [ResponseMapper.LatestServicePayment]
    typealias GetAllPaymentsService = RemoteServiceOf<LatestPaymentKind, GetAllPaymentsResult>
    
    static func getAllLatestPayments(
        httpClient: HTTPClient
    ) -> GetAllPaymentsService {
        
        return .init(
            createRequest: RequestFactory.createGetAllLatestPaymentsV2Request(_:),
            performRequest: httpClient.performRequest,
            mapResponse: ResponseMapper.mapGetAllLatestPaymentsResponse
        )
    }
}
