//
//  Dictionary+Options.swift
//  
//
//  Created by Andryusina Nataly on 09.06.2023.
//

import Foundation

public extension Dictionary where Key == SubscriptionType, Value == [OptionWithMapImage] {
    
    static let all: Self = [
        .monthly: .monthlyOptions,
        .yearly:  .yearlyOptions
    ]
}
