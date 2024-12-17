//
//  InputWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import RxViewModel
import SwiftUI

@available(*, deprecated, message: "Use `TextInputWrapperView`")
struct InputWrapperView<IconView: View>: View {
    
    @ObservedObject var viewModel: ViewModel
    
    let makeIconView: () -> IconView
    
    var body: some View {
        
        InputView(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: .iFora(keyboard: .default, limit: viewModel.state.settings.limit),
            iconView: makeIconView,
            commit: { viewModel.event(.edit($0)) },
            isValid: { $0.isValidate(regExp: viewModel.state.settings.regExp) }
        )
    }
}

extension InputWrapperView {
    
    typealias ViewModel = RxObservingViewModel<InputState<AnywayElement.UIComponent.Icon?>, InputEvent, Never>
}

