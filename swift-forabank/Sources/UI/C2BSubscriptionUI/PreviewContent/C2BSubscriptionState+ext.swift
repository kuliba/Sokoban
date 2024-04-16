//
//  C2BSubscriptionState+ext.swift
//  
//
//  Created by Igor Malyarov on 11.02.2024.
//

public extension C2BSubscriptionState {
    
    static let control: Self = .init(getC2BSubResponse: .control)
    static let empty: Self = .init(getC2BSubResponse: .empty)
}
