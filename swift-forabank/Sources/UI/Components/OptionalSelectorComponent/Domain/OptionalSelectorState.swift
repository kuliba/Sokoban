//
//  OptionalSelectorState.swift
//
//
//  Created by Igor Malyarov on 08.08.2024.
//

public struct OptionalSelectorState<Item> {
    
    public let items: [Item]
    public var filteredItems: [Item]
    public var isShowingItems: Bool
    public var selected: Item?
    public var searchQuery: String
    
    public init(
        items: [Item],
        filteredItems: [Item],
        isShowingItems: Bool = false,
        selected: Item? = nil,
        searchQuery: String = ""
    ) {
        self.items = items
        self.filteredItems = filteredItems
        self.isShowingItems = isShowingItems
        self.selected = selected
        self.searchQuery = searchQuery
    }
}

extension OptionalSelectorState: Equatable where Item: Equatable {}
