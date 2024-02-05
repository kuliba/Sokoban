//
//  ProductProfileView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.02.2024.
//

import SwiftUI
import CardGuardianModule
import ProductProfile

struct ProductProfileView: View {
    
    @ObservedObject var viewModel: ProductProfileViewModel
    
    @State var showingDetail = false
    
    var body: some View {
        
        openCardGuardinaButton()
    }
    
    private func openCardGuardinaButton() -> some View {
        
        Button(
            "Card Guardian",
            action: viewModel.openCardGuardian
        )
        .alert(
            item: .init(
                get: { viewModel.state.alert },
                set: { if $0 == nil { viewModel.event(.closeAlert) }}
            ),
            content: { .init(with: $0, event: viewModel.event) }
        )
        .sheet(
            item: .init(
                get: { viewModel.state.destination },
                set: { if $0 == nil { viewModel.event(.dismissDestination) }}
            ),
            content: destinationView
        )
    }
    
    private func destinationView(
        cgRoute: ProductProfileNavigation.State.ProductProfileRoute
    ) -> some View {
        
        CardGuardianModule.ThreeButtonsWrappedView(
            viewModel: cgRoute.viewModel,
            config: .preview)
        .padding(.top, 26)
        .padding(.bottom, 72)
    }
}


#Preview {
    ProductProfileView(
        viewModel: .init(
            initialState: .init(), navigationStateManager: .init(reduce: { _,_,_ in
                (ProductProfileNavigation.State.init(), .none)
            }, makeCardGuardianViewModel: { _ in
                
                    .init(
                        initialState: .init(buttons: .preview),
                        reduce: {_,_ in
                            (CardGuardianState.init(buttons: .preview), .none)
                        },
                        handleEffect: {_,_ in }
                    )
            })))
}

