//
//  ProductDetail.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Tagged

public struct ProductDetail: Equatable, Hashable {
    
    let id: DocumentItem.ID
    let title: String
    let value: Value
    let event: ProductDetailEvent
    
    var informerTitle: String {
        switch id {
            
        case .expirationDate:
            return "Срок действия карты"
            
        default:
            return title
        }
    }
    
    func subtitle(detailsState: DetailsState) -> String {
        
        switch value {
        case let .value(value):
            return value
        case let .valueWithMask(valueWithMask):
            switch detailsState {
            case .initial:
                return valueWithMask.maskedValue
            case .needShowNumber:
                if id == .number { return valueWithMask.value }
            case .needShowCvv:
                if id == .cvv { return valueWithMask.value}
            }
            return valueWithMask.maskedValue
        }
    }
}

public enum Value: Equatable, Hashable {
    
    case value(String)
    case valueWithMask(ValueWithMask)
    
    var copyValue: String {
        
        switch self {
        case let .value(value):
            return value
        case let .valueWithMask(valueWithMask):
            return valueWithMask.value
        }
    }
    
    public struct ValueWithMask: Equatable, Hashable {
        
        let value: String
        let maskedValue: String
        
        public init(
            value: String, 
            maskedValue: String
        ) {
            self.value = value
            self.maskedValue = maskedValue
        }
    }
}

public enum ProductDetailEvent: Equatable, Hashable {
    case longPress(ValueForCopy, TextForInformer)
    case iconTap(DocumentItem.ID)
    case share
    case selectAccountValue(Bool)
    case selectCardValue(Bool)
}

public extension ProductDetailEvent {
    
    typealias ValueForCopy = Tagged<_ValueForCopy, String>
    enum _ValueForCopy {}
    
    typealias TextForInformer = Tagged<_TextForInformer, String>
    enum _TextForInformer {}
}
