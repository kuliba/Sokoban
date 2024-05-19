//
//  TransactionStateWrapperView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct TransactionStateWrapperView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init(initialState: TransactionState) {
        
        let nanoServicesComposer = TransactionEffectHandlerNanoServicesComposer()
        let microServicesComposer = TransactionEffectHandlerMicroServicesComposer(
            nanoServices: nanoServicesComposer.compose()
        )
        let composer = TransactionViewModelComposer(
            composeMicroServices: microServicesComposer.compose
        )
        let viewModel = composer.compose(initialState: initialState)
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        TransactionView(
            state: viewModel.state,
            event: viewModel.event(_:)
        )
    }
}

extension TransactionStateWrapperView {
    
    typealias ViewModel = TransactionViewModel
}

#Preview {
    TransactionStateWrapperView(initialState: .preview)
}
