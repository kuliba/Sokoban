//
//  ContentView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isShowingEventList = false
    
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
            microServices: .stubbed(with: .init(
                initiatePayment: .success(.preview),
                makePayment: .init(
                    status: .completed,
                    info: .details("Operation Detail")
                ),
                processPayment: .success(.preview))
            )
        )
        
        self.viewModel = composer.compose(initialState: initialState)
    }
    
    var body: some View {
        
        NavigationView {
            
            AnywayTransactionStateWrapperView(viewModel: viewModel)
                .navigationTitle("Transaction View")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(
                        placement: .cancellationAction,
                        content: showEventListButton
                    )
                }
                .sheet(
                    isPresented: $isShowingEventList,
                    content: eventList
                )
        }
    }
    
    private func eventList() -> some View {
        
        NavigationView {
            
            EventList(event: viewModel.event(_:))
                .navigationTitle("Events")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(
                        placement: .cancellationAction,
                        content: {
                            Button("Close") { isShowingEventList = false }
                        }
                    )
                }
        }
    }
    
    private func showEventListButton() -> some View {
        
        Button { isShowingEventList = true } label: {
            
            Image(systemName: "arrowshape.turn.up.right.circle")
        }
    }
}

#Preview {
    ContentView()
}
