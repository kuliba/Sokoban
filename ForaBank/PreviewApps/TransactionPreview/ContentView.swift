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

    private let makeFactory: (@escaping (AnywayPaymentEvent) -> Void) -> AnywayPaymentFactory
    
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
        
        self.makeFactory = { event in
            
            let factory = AnywayPaymentElementViewFactory(
                widget: .init(
                    makeProductSelectView: { productID, observe in
                        
                        let products = getProducts()
                        let selected = products.first { $0.isMatching(productID) }
                        let initialState = ProductSelect(selected: selected)
                        
                        let reducer = ProductSelectReducer(getProducts: getProducts)
                        
                        let observable = ProductSelectViewModel(
                            initialState: initialState,
                            reduce: { (reducer.reduce($0, $1), nil) },
                            handleEffect: { _,_ in }
                        )
                        let observing = ObservingProductSelectViewModel(
                            observable: observable,
                            observe: {
                                
                                guard let productID = $0.selected?.coreProductID,
                                      let currency = $0.selected.map({ currencyOfProduct($0) })
                                else { return }
                                
                                observe(productID, .init(currency))
                            }
                        )
                        
                        return .init(viewModel: observing, config: .iFora)
                    }
                )
            )
            
            return .init(
                makeElementView: { .init(state: $0, event: event, factory: factory) },
                makeFooterView: { .init() }
            )
        }
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

private extension ProductSelect.Product {
    
    func isMatching(
        _ productID: AnywayPayment.Element.Widget.PaymentCore.ProductID
    ) -> Bool {
        
        switch productID {
        case let .accountID(accountID):
            return type == .account && id.rawValue == accountID.rawValue
            
        case let .cardID(cardID):
            return type == .card && id.rawValue == cardID.rawValue
        }
    }
    
    var coreProductID: AnywayPayment.Element.Widget.PaymentCore.ProductID {
        
        switch type {
        case .account:
            return .accountID(.init(id.rawValue))
            
        case .card:
            return .cardID(.init(id.rawValue))
        }
    }
}
