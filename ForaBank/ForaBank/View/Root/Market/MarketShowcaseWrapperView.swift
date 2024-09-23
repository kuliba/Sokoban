//
//  MarketShowcaseWrapperView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 23.09.2024.
//

import RxViewModel
import SwiftUI

typealias MarketShowcaseViewModel = RxViewModel<MarketShowcaseState, MarketShowcaseEvent, MarketShowcaseEffect>

struct MarketShowcaseWrapperView: View {
    
    let viewModel: MarketShowcaseViewModel
    let factory: ViewFactory
    
    init(
        viewModel: ViewModel,
        factory: ViewFactory
    ) {
        self.viewModel = viewModel
        self.factory = factory
    }

    var body: some View {
        
        MarketShowcaseView(
            state: viewModel.state,
            event: viewModel.event(_:),
            factory: factory,
            config: .iFora
        )
    }
}

extension MarketShowcaseWrapperView {
    
    typealias ViewModel = MarketShowcaseViewModel
    typealias ViewFactory = MarketShowcaseView.ViewFactory
    typealias Config = MarketShowcaseConfig
}

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
