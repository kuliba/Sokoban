//
//  OperatorGroup+ext.swift
//
//
//  Created by Igor Malyarov on 29.02.2024.
//

import ForaTools
import Foundation

public struct LoadOperatorsPayload<OperatorID: Hashable> {
    
    public let operatorID: OperatorID?
    public let searchText: String
    public let pageSize: Int
    
    public init(
        afterOperatorID operatorID: OperatorID? = nil,
        searchText: String = "",
        pageSize: Int
    ) {
        self.operatorID = operatorID
        self.searchText = searchText
        self.pageSize = pageSize
    }
}

public extension Array where Element == _OperatorGroup {

    func paged(with payload: LoadOperatorsPayload<String>) -> Self {
        
        let filtered = containing(payload.searchText)
        
        switch payload.operatorID {
        case .none:
            return .init(filtered.prefix(payload.pageSize))
            
        case let .some(operatorID):
            return filtered.page(
                startingAfter: operatorID,
                pageSize: payload.pageSize
            )
        }
    }
    
    private func containing(_ searchText: String) -> Self {
        
        guard !searchText.isEmpty else { return self }
        
        return filter { ($0.title.contains(searchText) || $0.description.contains(searchText)) }
    }
}

private extension OperatorGroup {
    
    func contains(_ searchText: String) -> Bool {
        
        guard !searchText.isEmpty else { return true }
        
        #warning("uncomment after adding `inn` field to OperatorGroup")
        return title.localizedCaseInsensitiveContains(searchText) //|| inn.localizedCaseInsensitiveContains(searchText)
    }
}
