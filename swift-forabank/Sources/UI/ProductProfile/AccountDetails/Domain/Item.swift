//
//  Item.swift
//  
//
//  Created by Andryusina Nataly on 06.03.2024.
//

import SwiftUI

struct Item: Equatable, Hashable {
        
    let id: DocumentItem.ID
    let title: String
    let titleForInformer: String
    var subtitle: String
    let valueForCopy: String
}

struct ItemActions {
    
    let actionForLongPress: (String, String) -> Void
    let actionForIcon: () -> Void
}
