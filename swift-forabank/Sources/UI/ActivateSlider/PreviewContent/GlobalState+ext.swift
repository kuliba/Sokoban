//
//  GlobalState+ext.swift
//
//
//  Created by Andryusina Nataly on 28.02.2024.
//

import Foundation

public extension GlobalState {
    
    static let initialState = GlobalState(
        cardState: .status(nil),
        offsetX: 0
    )
}
