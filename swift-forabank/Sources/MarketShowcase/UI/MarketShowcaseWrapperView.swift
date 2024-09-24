//
//  MarketShowcaseWrapperView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 24.09.2024.
//

import RxViewModel
import SwiftUI

public typealias MarketShowcaseViewModel = RxViewModel<MarketShowcaseState, MarketShowcaseEvent, MarketShowcaseEffect>

public typealias MarketShowcaseWrapperView<RefreshView> = RxWrapperView<MarketShowcaseView<RefreshView>, MarketShowcaseState, MarketShowcaseEvent, MarketShowcaseEffect> where RefreshView: View

public extension MarketShowcaseViewModel {
    
    func reset() {
        
    }
}

public extension MarketShowcaseViewModel {
    
    static let preview = MarketShowcaseViewModel.init(
        initialState: .inflight,
        reduce: { state,_ in return (state, nil) },
        handleEffect: { _,_ in })
}
