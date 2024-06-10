//
//  InputStateWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import PaymentComponents
import SwiftUI

struct InputStateWrapperView<IconView: View>: View {
    
    @StateObject var viewModel: ViewModel
    
    let makeIconView: () -> IconView
    
    var body: some View {
        
        InputView(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: .iFora,
            iconView: makeIconView
        )
    }
}

extension InputStateWrapperView {
    
    typealias ViewModel = ObservingInputViewModel
}
