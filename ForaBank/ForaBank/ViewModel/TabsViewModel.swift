//
//  TabsViewModel.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 23.09.2024.
//

import Foundation
import MarketShowcase

struct TabsViewModel {
    
    let mainViewModel: MainViewModel
    let paymentsModel: RootViewModel.PaymentsModel
    let chatViewModel: ChatViewModel
    let marketShowcaseModel: MarketShowcaseDomain.Binder
    
    func reset() {
        
        mainViewModel.reset()
        paymentsModel.reset()
        chatViewModel.reset()
        marketShowcaseModel.reset()
    }
}

extension MarketShowcaseDomain.Binder {
    
    func reset() {
        content.event(.resetSelection)
    }
}
extension TabsViewModel {
    
    static let preview: Self = .init(
        mainViewModel: .sample,
        paymentsModel: .legacy(.sample),
        chatViewModel: .init(),
        marketShowcaseModel: .preview)
}
