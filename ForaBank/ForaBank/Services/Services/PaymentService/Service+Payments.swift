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

    typealias GetJsonAbroadType = RequestFactory.GetJsonAbroadType
    typealias GetStickerDictionary = RemoteService<GetJsonAbroadType, StickerDictionaryResponse>

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
    
    typealias CommissionProductTransfer = RemoteService<RequestFactory.StickerPayment, CommissionProductTransferResponse>
    
    static func createCommissionProductTransferRequest(
        input: PaymentSticker.Operation,
        httpClient: HTTPClient
    ) -> CommissionProductTransfer {
        
        return .init(
            createRequest: RequestFactory.createCommissionProductTransfer,
            performRequest: httpClient.performRequest,
            mapResponse: {
                
                return try ResponseMapper.mapCommissionProductTransferResponse($0, $1).get()
            }
        )
    }
    
    typealias MakeTransfer = RemoteService<String, MakeTransferResponse>
    
    static func makeTransferRequest(
        httpClient: HTTPClient
    ) -> MakeTransfer {
        
        return .init(
            createRequest: RequestFactory.makeTransfer,
            performRequest: httpClient.performRequest,
            mapResponse: {
                
                return try ResponseMapper.mapMakeTransferResponse($0, $1).get()
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
