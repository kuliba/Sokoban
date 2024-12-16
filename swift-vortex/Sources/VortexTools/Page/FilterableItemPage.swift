//
//  FilterableItemPage.swift
//
//
//  Created by Igor Malyarov on 07.12.2024.
//

/// Extension on `Array` to return a paginated subset of `FilterableItem` elements that match a given query.
public extension Array
where Element: FilterableItem {
    
    /// Returns a filtered and paginated subset of elements matching the given query.
    ///
    /// Steps:
    /// 1. Filters items by `matches(_:)`.
    /// 2. Paginates results starting after `query.id` (if provided), returning up to `query.pageSize` items.
    func page(for query: Element.Query) -> Self {
        
        self.filter { $0.matches(query) }
            .page(startingAfter: query.id, pageSize: query.pageSize)
    }
}
