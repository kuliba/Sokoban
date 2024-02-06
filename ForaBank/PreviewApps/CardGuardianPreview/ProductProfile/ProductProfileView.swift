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
        
    var body: some View {
        
        openCardGuardianButton()
    }
    
    private func openCardGuardianButton() -> some View {
        
        Button(
            "Управление",
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
            config: viewModel.needBlockConfig ? .previewBlockHide : .preview)
        .padding(.top, 26)
        .padding(.bottom, 72)
        .presentationDetents([.height(300)])
    }
}

#Preview {
    ProductProfileView.cardBlockedHideOnMain
}

