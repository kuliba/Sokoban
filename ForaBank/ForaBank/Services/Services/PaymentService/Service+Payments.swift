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
    
    typealias CommissionProductTransferService = MappingRemoteService<RequestFactory.StickerPayment, CommissionProductTransfer, ResponseMapper.CommissionProductTransferError>
    
    static func makeCommissionProductTransferService(
        httpClient: HTTPClient
    ) -> CommissionProductTransferService {
        
        return .init(
            createRequest: RequestFactory.makeCommissionProductTransferRequest,
            performRequest: httpClient.performRequest,
            mapResponse: ResponseMapper.mapCommissionProductTransferResponse
        )
    }
    
    typealias TransferService = MappingRemoteService<String, MakeTransfer, ResponseMapper.MakeTransferError>
    
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

