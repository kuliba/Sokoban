//
//  Detail.swift
//
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import Tagged

public struct Detail: Equatable, Hashable {
    
    let id: DocumentItem.ID
    let title: String
    let titleForInformer: String
    var subtitle: String
    let valueForCopy: String
    let event: DetailEvent
}

public enum DetailEvent: Equatable, Hashable {
    case longPress(ValueForCopy, TextForInformer)
    case iconTap(DocumentItem.ID)
}

public extension DetailEvent {
    
    typealias ValueForCopy = Tagged<_ValueForCopy, String>
    enum _ValueForCopy {}
    
    typealias TextForInformer = Tagged<_TextForInformer, String>
    enum _TextForInformer {}
}
