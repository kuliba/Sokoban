//
//  InputStateWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import PaymentComponents
import RxViewModel
import SwiftUI

typealias ObservingInputViewModel = RxObservingViewModel<InputState<String>, InputEvent, Never>

struct InputStateWrapperView: View {
    
    @StateObject private var viewModel: ViewModel
    
    private let factory: Factory
    
    init(
        viewModel: ViewModel,
        factory: Factory
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.factory = factory
    }
    
    var body: some View {
        
        InputView(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: .iFora,
            iconView: factory.makeIconView
        )
    }
}

extension InputStateWrapperView {
    
    typealias ViewModel = ObservingInputViewModel
    typealias Factory = InputStateWrapperViewFactory
}
