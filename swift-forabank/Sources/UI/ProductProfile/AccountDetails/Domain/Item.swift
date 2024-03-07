//
//  Item.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Tagged

public struct Item: Equatable, Hashable {
    
    let id: DocumentItem.ID
    let title: String
    let titleForInformer: String
    var subtitle: String
    let valueForCopy: String
    let event: ItemEvent
}

public enum ItemEvent: Equatable, Hashable {
    case longPress(ValueForCopy, TextForInformer)
    case iconTap(DocumentItem.ID)
}

public extension ItemEvent {
    
    typealias ValueForCopy = Tagged<_ValueForCopy, String>
    enum _ValueForCopy {}
    
    typealias TextForInformer = Tagged<_TextForInformer, String>
    enum _TextForInformer {}
}
