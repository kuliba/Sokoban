//
//  DynamicParams.swift
//
//
//  Created by Andryusina Nataly on 24.01.2024.
//

import Foundation

public protocol DynamicParams {
    
    var balance: Decimal? { get }
    var balanceRub: Decimal? { get }
    var customName: String? { get }
}
