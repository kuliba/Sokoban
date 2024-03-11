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
    var subtitle: String
    let copyValue: String
    let event: ProductDetailEvent
    
    var informerTitle: String {
        switch id {
            
        case .expirationDate:
            return "Срок действия карты"
            
        default:
            return title
        }
    }
}

public enum ProductDetailEvent: Equatable, Hashable {
    case longPress(ValueForCopy, TextForInformer)
    case iconTap(DocumentItem.ID)
}

public extension ProductDetailEvent {
    
    typealias ValueForCopy = Tagged<_ValueForCopy, String>
    enum _ValueForCopy {}
    
    typealias TextForInformer = Tagged<_TextForInformer, String>
    enum _TextForInformer {}
}
