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
