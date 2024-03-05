//
//  ProductDetails.swift
//
//
//  Created by Andryusina Nataly on 05.03.2024.
//

import Foundation

public struct ProductDetails: Equatable {
    
    let details: Details
    
    public init(
        details: Details
    ) {
        self.details = details
    }
}
