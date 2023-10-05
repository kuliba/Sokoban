//
//  StickerPaymentData.swift
//  
//
//  Created by Дмитрий Савушкин on 04.10.2023.
//

import Foundation

public struct StickerPaymentData: Decodable {
    
    let statusCode: Int
    let errorMessage: String?
    let data: Payment?
    
    public struct Payment: Decodable {
        
        public let header: [DataView]?
        public let main: [DataView]
        
        init(
            header: [StickerPaymentData.Payment.DataView]?,
            main: [StickerPaymentData.Payment.DataView]
        ) {
            self.header = header
            self.main = main
        }
    }
}

extension StickerPaymentData.Payment {
    
    enum PaymentComponentsType: String, Codable, Equatable {
        
        case citySelector = "CITY_SELECTOR"
        case productInfo = "PRODUCT_INFO"
        case textsWithIconHorizontal = "TEXTS_WITH_ICON_HORIZONTAL"
        case productSelect = "PRODUCT_SELECT"
        case verticalSelector = "VERTICAL_SELECTOR"
    }

    public enum DataView: Codable {
        
        case citySelector
        case productInfo
        case textsWithIconHorizontal
        case productSelect
        case verticalSelector
    }
}

extension StickerPaymentData.Payment.DataView {
    
    init?(
        data: StickerPaymentData.Payment.DataView
    ) {
        
        switch data {
        case .citySelector:
            self = .citySelector
            
        case .productInfo:
            self = .productInfo
            
        case .productSelect:
            return nil
            
        case .textsWithIconHorizontal:
            self = .textsWithIconHorizontal
            
        case .verticalSelector:
            self = .verticalSelector
        }
    }
    
    public var parameter: PaymentsComponents.Operation.Parameter {
       
        switch self {
        case .citySelector:
            return .selector(.init())
        case .productInfo:
            return .sticker(.init())
        case .textsWithIconHorizontal:
            return .hint(.init())
        case .productSelect:
            return .product(.init())
        case .verticalSelector:
            return .selector(.init())
        }
    }
}
