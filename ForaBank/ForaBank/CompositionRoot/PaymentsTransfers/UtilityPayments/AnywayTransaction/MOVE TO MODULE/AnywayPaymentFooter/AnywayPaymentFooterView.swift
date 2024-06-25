//
//  AnywayPaymentFooterView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import SwiftUI

struct AnywayPaymentFooterView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    let config: Config
    
    var body: some View {
        
        FooterStateWrapperView(
            viewModel: viewModel,
            config: config,
            infoView: EmptyView.init
        )
    }
}

extension AnywayPaymentFooterView {
    
    typealias ViewModel = FooterViewModel
    typealias Config = BottomAmountConfig
}
