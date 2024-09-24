//
//  MarketShowcaseWrapperView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 23.09.2024.
//

import RxViewModel
import SwiftUI

typealias MarketShowcaseViewModel = RxViewModel<MarketShowcaseState, MarketShowcaseEvent, MarketShowcaseEffect>


typealias MarketShowcaseWrapperView = RxWrapperView<MarketShowcaseView, MarketShowcaseState, MarketShowcaseEvent, MarketShowcaseEffect>

extension MarketShowcaseViewModel {
    
    func reset() {
        
    }
}

extension MarketShowcaseViewModel {
    
    static let preview = MarketShowcaseViewModel.init(
        initialState: .inflight,
        reduce: { state,_ in return (state, nil) },
        handleEffect: { _,_ in })
}
