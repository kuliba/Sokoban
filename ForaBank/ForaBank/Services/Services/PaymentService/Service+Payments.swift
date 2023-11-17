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
    typealias GetStickerDictionaryService = MappingRemoteService<GetJsonAbroadType, StickerDictionaryResponse, ResponseMapper.StickerDictionaryError>

    static func makeGetStickerDictService(
        httpClient: HTTPClient
    ) -> GetStickerDictionaryService {
        
        return .init(
            createRequest: RequestFactory.makeGetStickerDictionaryRequest,
            performRequest: httpClient.performRequest,
            mapResponse: ResponseMapper.mapStickerDictionaryResponse
        )
    }
    
    typealias CommissionProductTransferService = MappingRemoteService<RequestFactory.StickerPayment, CommissionProductTransferResponse, ResponseMapper.CommissionProductTransferError>
    
    static func makeCommissionProductTransferService(
        httpClient: HTTPClient
    ) -> CommissionProductTransferService {
        
        return .init(
            createRequest: RequestFactory.makeCommissionProductTransferRequest,
            performRequest: httpClient.performRequest,
            mapResponse: ResponseMapper.mapCommissionProductTransferResponse
        )
    }
    
    typealias TransferService = MappingRemoteService<String, MakeTransferResponse, ResponseMapper.MakeTransferError>
    
    static func makeTransferService(
        httpClient: HTTPClient
    ) -> TransferService {
        
        return .init(
            createRequest: RequestFactory.makeTransferRequest,
            performRequest: httpClient.performRequest,
            mapResponse: ResponseMapper.mapMakeTransferResponse
        )
    }
    
    typealias ImageListService = MappingRemoteService<[String], [ImageData], ResponseMapper.GetImageListError>
    
    static func makeImageListService(
        httpClient: HTTPClient
    ) -> ImageListService {
        
        return .init(
            createRequest: RequestFactory.makeImageListRequest,
            performRequest: httpClient.performRequest,
            mapResponse: ResponseMapper.getImageListResponse
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
