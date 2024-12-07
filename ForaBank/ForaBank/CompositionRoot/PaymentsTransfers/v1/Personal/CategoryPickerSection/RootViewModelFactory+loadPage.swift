//
//  RootViewModelFactory+loadPage.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2024.
//

import ForaTools

extension RootViewModelFactory {
    
    /// Loads and returns a paginated subset of decodable, filterable items.
    ///
    /// - Parameters:
    ///   - type: The decodable array type to load. Defaults to `[T].self`.
    ///   - query: Defines the paging and filtering criteria.
    /// - Returns: A filtered, paginated array of items, or `nil` if none were found.
    @inlinable
    func loadPage<T: Decodable & FilterableItem>(
        of type: [T].Type = [T].self,
        for query: T.Query
    ) -> [T]? {
        
        guard let items = logDecoratedLocalLoad(type: type)
        else { return nil }
        
        let page = items.page(for: query)
        debugLog(pageCount: page.count, of: items.count)
        
        return page
    }
}
