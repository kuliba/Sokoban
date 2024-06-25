//
//  InputWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import PaymentComponents
import SwiftUI

struct InputWrapperView<IconView: View>: View {
    
    @ObservedObject var viewModel: ViewModel
    
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

extension InputWrapperView {
    
    typealias ViewModel = ObservingInputViewModel
}
