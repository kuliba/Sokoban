//
//  ResponseMapper+getJsonAbroadDict.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 01.11.2023.
//

import Foundation

extension ResponseMapper {
    
    typealias StickerDictionaryResult = Result<StickerDictionaryResponse, StickerDictionaryError>
    
    static func mapStickerDictionaryResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> StickerDictionaryResult {
        
        do {
            
            switch httpURLResponse.statusCode {
            case 200:
                    
                let stickerDictionary = try JSONDecoder().decode(_StickerDictionary.self, from: data)
                return .success(stickerMapper(stickerDecodable: stickerDictionary))
                
            default:
                
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                return .failure(.error(
                    statusCode: serverError.statusCode,
                    errorMessage: serverError.errorMessage
                ))
            }
            
        } catch {
            return .failure(.invalidData(
                statusCode: httpURLResponse.statusCode, data: data
            ))
            
        }
    }
    
    enum StickerDictionaryError: Error , Equatable {
        
        case error(
            statusCode: Int,
            errorMessage: String
        )
        case invalidData(statusCode: Int, data: Data)
    }
}

extension ResponseMapper {
    
    private static func stickerMapper(
        stickerDecodable: _StickerDictionary
    ) -> StickerDictionaryResponse {
        
        switch stickerDecodable {
        case let .deliveryType(deliveryType):
            return .deliveryType(.init(
                main: deliveryType.main.map({
                    StickerDictionaryResponse.Main(type: .init(componentType: $0.type), data: .init(dataType: $0.data))
                }),
                serial: deliveryType.serial
            ))
        case let .orderForm(orderForm):
            return .orderForm(.init(
                header: orderForm.header.map({
                    StickerDictionaryResponse.StickerOrderForm.Header(
                        type: .init(componentType: $0.type),
                        data: .init(title: $0.data.title, isFixed: $0.data.isFixed))
                }),
                main: orderForm.main.map({
                    StickerDictionaryResponse.Main(
                        type: .init(componentType: $0.type),
                        data: .init(dataType: $0.data))
                }),
                footer: [],
                serial: orderForm.serial
            ))
        }
    }
}
