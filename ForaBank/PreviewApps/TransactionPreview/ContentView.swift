//
//  ContentView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct ContentView: View {
    
    private let viewModel: AnywayTransactionViewModel
    
    init() {
        
        let initialState: AnywayTransactionState = .preview
        
        let microServicesComposer = AnywayTransactionEffectHandlerMicroServicesComposer(
            nanoServices: .stubbed(with: .init(
                getDetailsResult: "Operation Detail",
                makeTransferResult: .init(
                    status: .completed,
                    detailID: 54321
                )
            ))
        )
        
        let composer = AnywayTransactionViewModelComposer(
            composeMicroServices: {
                
                return .stubbed(with: .init(
                    initiatePayment: .success(.preview),
                    makePayment: .init(
                        status: .completed,
                        info: .details("Operation Detail")
                    ),
                    processPayment: .success(.preview))
                )
            }
        )
        
        self.viewModel = composer.compose(initialState: initialState)
    }
    
    var body: some View {
        
        NavigationView {
            
            AnywayTransactionStateWrapperView(viewModel: viewModel)
                .navigationTitle("Transaction View")
        }
    }
}

#Preview {
    ContentView()
}
