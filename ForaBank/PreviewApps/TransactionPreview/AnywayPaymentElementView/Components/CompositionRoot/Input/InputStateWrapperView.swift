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

struct InputStateWrapperView<InputView>: View
where InputView: View {
    
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
        
        factory.makeInputView(viewModel.state, viewModel.event(_:))
    }
}

extension InputStateWrapperView {
    
    typealias ViewModel = ObservingInputViewModel
    typealias Factory = InputStateWrapperViewFactory<InputView>
}
//
//#Preview {
//    InputStateWrapperView()
//}
