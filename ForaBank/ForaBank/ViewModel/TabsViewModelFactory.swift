//
//  TabsViewModelFactory.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 23.09.2024.
//

import Foundation
import MarketShowcase

struct TabsViewModelFactory {
    
    let mainViewModel: MainViewModel
    let paymentsModel: RootViewModel.PaymentsModel
    let chatViewModel: ChatViewModel
    let marketShowcaseModel: MarketShowcaseViewModel
    
    func reset() {
        
        mainViewModel.reset()
        paymentsModel.reset()
        chatViewModel.reset()
        marketShowcaseModel.reset()
    }
}

extension TabsViewModelFactory {
    
    static let preview: Self = .init(
        mainViewModel: .sample,
        paymentsModel: .legacy(.sample),
        chatViewModel: .init(),
        marketShowcaseModel: .preview)
}
