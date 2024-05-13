//
//  PaginatePayload.swift
//
//
//  Created by Igor Malyarov on 13.05.2024.
//

public struct PaginatePayload<OperatorID> {
    
    public let operatorID: OperatorID
    public let pageSize: PageSize
    public let searchText: String
    
    public init(
        operatorID: OperatorID,
        pageSize: PageSize,
        searchText: String
    ) {
        self.operatorID = operatorID
        self.pageSize = pageSize
        self.searchText = searchText
    }
}

public extension PaginatePayload {
    
    typealias PageSize = Int
}

extension PaginatePayload: Equatable where OperatorID: Equatable {}
