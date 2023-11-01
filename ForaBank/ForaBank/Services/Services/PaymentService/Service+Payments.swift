//
//  Service+Payments.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.10.2023.
//

import Foundation
import GenericRemoteService

extension Services {

    typealias StickerDictionary = ResponseMapper.StickerDictionary
    typealias GetJsonAbroadType = RequestFactory.GetJsonAbroadType
    typealias GetStickerDictionary = RemoteService<GetJsonAbroadType, StickerDictionary>

    static func stickerDictRequest(
        input: RequestFactory.GetJsonAbroadType,
        httpClient: HTTPClient
    ) -> GetStickerDictionary {
        
        return .init(
            createRequest: RequestFactory.getStickerDictionary,
            performRequest: httpClient.performRequest,
            mapResponse: { _,_ in
                    .deliveryCourier(.init(main: [], serial: ""))
            }
        )
    }
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
