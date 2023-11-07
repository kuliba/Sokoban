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

    typealias GetStickerDictionary = RemoteService<String, PaymentSticker.Operation>

    static func stickerDictRequest(
        input: RequestFactory.GetJsonAbroadType,
        httpClient: HTTPClient
    ) -> GetStickerDictionary {
        
        return .init(
            createRequest: RequestFactory.getStickerDictionary,
            performRequest: httpClient.performRequest,
            mapResponse: {
                
                let dictionaryResponse = try ResponseMapper.mapStickerDictionaryResponse($0, $1).get()
                
                switch dictionaryResponse {
                case .orderForm(let stickerOrderForm):
                    return PaymentSticker.Operation(parameters: [])
                    
                case .deliveryOffice(let deliveryOffice):
                    return PaymentSticker.Operation(parameters: [])
                    
                case .deliveryCourier(let deliveryCourier):
                    return PaymentSticker.Operation(parameters: [])
                }
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
