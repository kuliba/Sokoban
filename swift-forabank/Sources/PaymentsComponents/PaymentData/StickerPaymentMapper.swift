//
//  StickerPaymentMapper.swift
//  
//
//  Created by Дмитрий Савушкин on 04.10.2023.
//

import Foundation

public struct StickerPaymentMapper {
    
    public typealias Result = Swift.Result<StickerPaymentData.Payment, MapperError>
    
    public static func map(
        _ data: Data,
        _ response: HTTPURLResponse
    ) -> Result {
        
        guard response.statusCode == 200 else {
            return .failure(.notOkStatus)
            
        }
        return dataToParameters(data)
    }
    
    public enum MapperError: Error {
        
        case notOkStatus
        case mapError
    }
    
    private static func dataToParameters(_ data: Data) -> Result {
        
        if let decoded = try? decode(data) {
            let payment = Self.decodeDataToStickerPayment(decoded)
            return .success(payment)
        }
        return .failure(.mapError)
    }
    
    private static func decode(_ data: Data) throws -> StickerPaymentData {
        
        let str = String(decoding: data, as: UTF8.self)
        let correctedString = str.replacingOccurrences(of: ".\n", with: ".\\n")
        let dataCorrected: Data = correctedString.data(using: .utf8) ?? .init()
        
        return try JSONDecoder().decode(StickerPaymentData.self, from: dataCorrected)
    }
    
    private static func decodeDataToStickerPayment(
        _ decodeLanding: StickerPaymentData
    ) -> StickerPaymentData.Payment {
        
        typealias DataView = StickerPaymentData.Payment.DataView
        typealias Payment = StickerPaymentData.Payment
        
        let header: [DataView] = decodeLanding.data?.header?
            .compactMap(DataView.init(data:)) ?? []
        
        let main: [DataView] = decodeLanding.data?.main
            .compactMap(DataView.init(data:)) ?? []
        
        let payment: Payment = .init(
            header: header,
            main: main
        )
        
        return payment
    }
}
