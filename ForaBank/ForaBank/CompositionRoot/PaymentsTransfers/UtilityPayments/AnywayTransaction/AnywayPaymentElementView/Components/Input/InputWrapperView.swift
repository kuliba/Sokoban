//
//  InputWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import PaymentComponents
import SwiftUI

struct InputWrapperView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    let factory: Factory
    
    var body: some View {
        
        InputView(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: .iFora,
            iconView: factory.makeIconView
        )
    }
}

extension InputWrapperView {
    
    typealias ViewModel = ObservingInputViewModel
    typealias Factory = InputStateWrapperViewFactory
}
