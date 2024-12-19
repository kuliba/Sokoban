//
//  PaginatePayload.swift
//
//
//  Created by Igor Malyarov on 13.05.2024.
//

public struct PaginatePayload<OperatorID> {
    
    public let operatorID: OperatorID
    public let searchText: String
    
    public init(
        operatorID: OperatorID,
        searchText: String
    ) {
        self.operatorID = operatorID
        self.searchText = searchText
    }
}

extension PaginatePayload: Equatable where OperatorID: Equatable {}
