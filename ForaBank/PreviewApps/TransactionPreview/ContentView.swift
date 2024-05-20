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
            composeMicroServices: {
                
                return .stubbed(with: .init(
                    initiatePayment: .success(123),
                    makePayment: .init(
                        status: .completed,
                        info: .details("Operation Detail")
                    ),
                    paymentEffectHandle: .anEvent,
                    processPayment: .success(456))
                )
            }
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
