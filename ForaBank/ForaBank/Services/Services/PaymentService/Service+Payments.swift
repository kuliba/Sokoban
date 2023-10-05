//
//  Service+Payments.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.10.2023.
//

import Foundation
import GenericRemoteService
import PaymentsComponents

extension Services {
    
    typealias GetStickerPayment = String
    typealias GetPaymentService = RemoteService<GetStickerPayment, [PaymentsComponents.Operation.Parameter]>
    typealias Parameter = PaymentsComponents.Operation.Parameter
    
    static func getPaymentService(
        httpClient: HTTPClient
    ) -> GetPaymentService {
        
        let map: (Data, HTTPURLResponse) throws -> [Parameter] = { data, response in
            
            let result = StickerPaymentMapper.map(data, response)
            return try result.get().main.map(\.parameter)
        }
        
        return .init(
            createRequest: RequestFactory.stickerPaymentRequest,
            performRequest: httpClient.performRequest,
            mapResponse: map
        )
    }
}
