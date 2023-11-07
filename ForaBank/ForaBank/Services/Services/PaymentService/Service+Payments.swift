//
//  Service+Payments.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.10.2023.
//

import Foundation
import GenericRemoteService
import PaymentSticker

extension Services {

    typealias GetStickerDictionary = RemoteService<String, StickerDictionaryResponse>

    static func stickerDictRequest(
        input: RequestFactory.GetJsonAbroadType,
        httpClient: HTTPClient
    ) -> GetStickerDictionary {
        
        return .init(
            createRequest: RequestFactory.getStickerDictionary,
            performRequest: httpClient.performRequest,
            mapResponse: {
                
                return try ResponseMapper.mapStickerDictionaryResponse($0, $1).get()
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
