//
//  FilterEffect.swift
//
//
//  Created by Дмитрий Савушкин on 20.09.2024.
//

import Foundation

public enum FilterEffect: Equatable {
    
    case resetPeriod(Int)
    case updateFilter(UpdateFilterPayload)
    
    public struct UpdateFilterPayload: Equatable {

        public let range: Range<Date>
        public let productId: Int
        
        public init(
            range: Range<Date>,
            productId: Int
        ) {
            self.range = range
            self.productId = productId
        }
    }
}
