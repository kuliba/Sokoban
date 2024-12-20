//
//  DynamicParamsList.swift
//
//
//  Created by Andryusina Nataly on 25.01.2024.
//

import Foundation

public struct DynamicParamsList: Equatable {
    
    public let list: [DynamicParamsItem]
    
    public init(list: [DynamicParamsItem]) {
        self.list = list
    }
}
