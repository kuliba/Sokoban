//
//  SearchPayload.swift
//  
//
//  Created by Igor Malyarov on 13.05.2024.
//

public struct SearchPayload: Equatable {
    
    public let pageSize: PageSize
    public let searchText: String
    
    public init(
        pageSize: PageSize,
        searchText: String
    ) {
        self.pageSize = pageSize
        self.searchText = searchText
    }
}

public extension SearchPayload {
    
    typealias PageSize = Int
}
