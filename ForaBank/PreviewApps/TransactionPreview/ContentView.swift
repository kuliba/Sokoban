//
//  ContentView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import AnywayPaymentDomain
import PaymentComponents
import RxViewModel
import SwiftUI

#warning("Composition Root")
typealias ProductSelectViewModel = RxViewModel<ProductSelect, ProductSelectEvent, Never>

struct ContentView: View {
    
    @StateObject private var viewModel: ContentViewModel

    private let makeFactory: (@escaping (AnywayPaymentEvent) -> Void) -> AnywayPaymentFactory<Text>
    
    init() {
        
        self._viewModel = .init(wrappedValue: .default())
        
#warning("Composition Root")
        let getProducts: () -> [ProductSelect.Product] = {
#warning("FIXME")
            return [.accountPreview, .cardPreview]
        }
        let currencyOfProduct: (ProductSelect.Product) -> String = { _ in
#warning("FIXME")
            return "RUB"
        }
        
        let composer = AnywayPaymentFactoryComposer(
            config: .init(info: .preview),
            currencyOfProduct: currencyOfProduct,
            getProducts: getProducts
        )
        
        self.makeFactory = composer.compose(event:)
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
        .onAppear(perform: viewModel.openPayment)
    }
    
    @ViewBuilder
    private func destinationView(
        destination: Flow.Destination
    ) -> some View {
        
        switch destination {
        case let .payment(transactionViewModel):
            let factory = makeFactory(
               { transactionViewModel.event(.payment($0)) }
            )
            AnywayTransactionStateWrapperView(
                viewModel: transactionViewModel,
                factory: factory
            )
            .navigationTitle("Transaction View")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction,
                    content: showEventListButton
                )
                ToolbarItem(
                    placement: .confirmationAction,
                    content: {
                    
                        Button {
                            dump(transactionViewModel.state)
                        } label: {
                            Image(systemName: "printer")
                        }

                    }
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
