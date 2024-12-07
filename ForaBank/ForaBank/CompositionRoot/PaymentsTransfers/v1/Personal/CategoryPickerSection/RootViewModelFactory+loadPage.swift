//
//  RootViewModelFactory+loadPage.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.12.2024.
//

import ForaTools

extension RootViewModelFactory {
    
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
