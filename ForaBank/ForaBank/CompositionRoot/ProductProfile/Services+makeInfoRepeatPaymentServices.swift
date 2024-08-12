//
//  Services+makeInfoRepeatPaymentServices.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 06.08.2024.
//

import Foundation
import GetInfoRepeatPaymentService
import GenericRemoteService
import RemoteServices

extension Services {
    
    static func makeInfoRepeatPaymentServices(
        httpClient: HTTPClient,
        log: @escaping (String, StaticString, UInt) -> Void
    ) -> InfoRepeatPaymentServices {
        
        let createInfoRepeatPaymentServices = RemoteService(
            createRequest: RequestFactory.getInfoForRepeatPayment,
            performRequest: httpClient.performRequest(_:completion:),
            mapResponse: GetInfoRepeatPaymentMapper.mapResponse
        ).process(_:completion:)
        
        return .init(
            createInfoRepeatPaymentServices: createInfoRepeatPaymentServices
        )
    }
}
