//
//  ContentView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct ContentView: View {
    
    private let viewModel: TransactionViewModel
    
    init() {
        
        let initialState: TransactionState = .preview
        
        let microServicesComposer = TransactionEffectHandlerMicroServicesComposer(
            nanoServices: .stubbed(with: .init(
                getDetailsResult: "Operation Detail",
                makeTransferResult: .init(
                    status: .completed,
                    detailID: 54321
                )
            ))
        )
        let composer = TransactionViewModelComposer(
            composeMicroServices: microServicesComposer.compose
        )
        
        self.viewModel = composer.compose(initialState: initialState)
    }
    
    var body: some View {
        
        TransactionStateWrapperView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
