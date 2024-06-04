//
//  Item.swift
//  AutoScrollingListPreview
//
//  Created by Igor Malyarov on 29.05.2024.
//

struct Item: Identifiable, Equatable {
    
    let id: Int
    
    var name: String { "Item #\(id)" }
}
