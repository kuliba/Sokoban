//
//  Service+Payments.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.10.2023.
//

import Foundation
import GenericRemoteService

extension Services {

    typealias GetStickerPayment = StickerPayment
    typealias GetPaymentService = RemoteService<RequestFactory.StickerPayment, Parameter>

    static func stickerPaymentRequest(
        input: RequestFactory.StickerPayment,
        httpClient: HTTPClient
    ) -> GetPaymentService {
        
        return .init(
            createRequest: RequestFactory.stickerCreatePayment,
            performRequest: httpClient.performRequest,
            mapResponse: { _,_ in .init() }
        )
    }
}

struct ApiError {}

struct Parameter {
    
}

struct StickerPayment {
    
    let currencyAmount: String
    let amount: String
    let check: Bool
    let payer: Payer
    let productToOrderInfo: Order
    
    struct Payer {
        
        let cardId: String
    }
    
    struct Order {
        
        let type: String
        let deliverToOffice: Bool
        let officeId: String
    }
}

struct StickerPaymentMapper {
    
    func map() -> [Parameter] {
        
        [.init()]
    }
}
