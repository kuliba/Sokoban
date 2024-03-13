//
//  ProductDetailsView.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 11.03.2024.
//

import SwiftUI
import ProductProfile
import ProductDetailsUI

struct ProductDetailsView: View {
    
    let state: ProductProfileNavigation.State
    let event: (ProductProfileNavigation.Event) -> Void
    
    var body: some View {
        
        detailsButton()
    }
    
    private func detailsButton() -> some View {
        
        Button(
            "Реквизиты",
            action: { self.event(.create(.productDetails)) }
        )
        .buttonStyle(.bordered)
        .controlSize(.large)
        .sheet(
            item: .init(
                get: {
                    if case let .productDetails(route) = state.modal {
                        return route
                    } else { return nil }
                },
                set: { if $0 == nil { event(.dismissDestination) }}
            ),
            content: destinationView
        )
        .navigationDestination(
            item: .init(
                get: { state.destination },
                set: { if $0 == nil { event(.dismissDestination) }}
            ),
            destination: destinationView
        )
    }
    
    private func destinationView(
        route: ProductProfileNavigation.State.ProductDetailsRoute
    ) -> some View {
        
        ProductDetailsWrappedView(
            viewModel: route.viewModel,
            config: .preview
        )
        .alert(
            item: .init(
                get: { state.alert },
                // set is called by tapping on alert buttons, that are wired to some actions, no extra handling is needed (not like in case of modal or navigation)
                set: { _ in }
            ),
            content: { .init(with: $0, event: event) }
        )
        .sheet(
            item: .init(
                get: {
                    if case let .share(route) = state.modal {
                        return route
                    } else { return nil }
                },
                set: { if $0 == nil { event(.dismissDestination) }}
            ),
            content: sheetView
        )
    }
    
    private func sheetView(
        route: ProductProfileNavigation.State.ProductDetailsSheetRoute
    ) -> some View {
        
        ProductDetailsSheetWrappedView(
            viewModel: route.viewModel,
            config: .preview
        )
        .presentationDetents([.height(374)])
    }
}

#Preview {
    ProductDetailsView.init(
        state: .init(),
        event: { _ in })
}

