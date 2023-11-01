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
    typealias GetPaymentService = RemoteService<RequestFactory.GetJsonAbroadType, StickerPayment>

    static func stickerPaymentRequest(
        input: RequestFactory.GetJsonAbroadType,
        httpClient: HTTPClient
    ) -> GetPaymentService {
        
        return .init(
            createRequest: RequestFactory.getStickerDictionary,
            performRequest: httpClient.performRequest,
            mapResponse: ResponseMapper.mapStickerDictionaryResponse
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
