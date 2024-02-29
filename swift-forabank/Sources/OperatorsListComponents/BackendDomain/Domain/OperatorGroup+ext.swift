//
//  OperatorGroup+ext.swift
//
//
//  Created by Igor Malyarov on 29.02.2024.
//

import ForaTools

public struct LoadOperatorsPayload {
    
    let operatorID: Operator.ID?
    let searchText: String
    let pageSize: Int
    
    public init(
        operatorID: Operator.ID? = nil,
        searchText: String = "",
        pageSize: Int
    ) {
        self.operatorID = operatorID
        self.searchText = searchText
        self.pageSize = pageSize
    }
}

public extension Array where Element == OperatorGroup {

    @available(*, deprecated, renamed: "paged", message: "Use `paged` instead.")
    func filtered(with payload: LoadOperatorsPayload) -> Self {
        
        paged(with: payload)
    }
    
    func paged(with payload: LoadOperatorsPayload) -> Self {
        
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
        
        return filter { $0.contains(searchText) }
    }
}

private extension OperatorGroup {
    
    func contains(_ searchText: String) -> Bool {
        
        guard !searchText.isEmpty else { return true }
        
        #warning("uncomment after adding `inn` field to OperatorGroup")
        return title.contains(searchText) //|| inn.contains(searchText)
    }
}
