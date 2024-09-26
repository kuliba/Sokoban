//
//  MarketShowcaseDomainBinder+preview.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 25.09.2024.
//

import Foundation

extension MarketShowcaseDomain.Binder {
    
    static let preview = MarketShowcaseDomain.Binder(
        content: .init(
            initialState: .init(status: .initiate),
            reduce: { state,_ in  (state, nil)},
            handleEffect: {_,_ in }),
        flow: .init(
            initialState: .init(),
            reduce: { state,_ in  (state, nil)},
            handleEffect: {_,_ in }),
        bind: { _,_ in [] })
}
