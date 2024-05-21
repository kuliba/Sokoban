//
//  ContentView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel: ContentViewModel
    
    init() {
     
        self._viewModel = .init(wrappedValue: .default())
    }
    
    var body: some View {
        
        NavigationView {
            
            Button("Payment", action: viewModel.openPayment)
                .navigationDestination(
                    destination: viewModel.flow.destination,
                    dismissDestination: viewModel.dismissDestination,
                    content: destinationView
                )
        }
    }
    
    private func destinationView(
        destination: Flow.Destination
    ) -> some View {
        
        switch destination {
        case let .payment(transactionViewModel):
            AnywayTransactionStateWrapperView(viewModel: transactionViewModel)
                .navigationTitle("Transaction View")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(
                        placement: .cancellationAction,
                        content: showEventListButton
                    )
                }
                .sheet(
                    modal: viewModel.flow.modal,
                    dismissModal: viewModel.hideEventList,
                    content: { sheetView(transactionViewModel, modal: $0) }
                )
        }
    }
    
    @ViewBuilder
    private func sheetView(
        _ transactionViewModel: ObservingAnywayTransactionViewModel,
        modal: Flow.Modal
    ) -> some View {
        
        switch modal {
        case .fraud:
            NavigationView {
                
                Text("Fraud suspected!")
                    .foregroundColor(.red)
            }
            
        case .eventList:
            NavigationView {
                
                EventList(event: transactionViewModel.event(_:))
                    .navigationTitle("Events")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(
                            placement: .cancellationAction,
                            content: {
                                Button("Close", action: viewModel.hideEventList)
                            }
                        )
                    }
            }
        }
    }
    
    private func showEventListButton() -> some View {
        
        Button(action: viewModel.showEventList) {
            
            Image(systemName: "arrowshape.turn.up.right.circle")
        }
    }
}

#Preview {
    ContentView()
}
