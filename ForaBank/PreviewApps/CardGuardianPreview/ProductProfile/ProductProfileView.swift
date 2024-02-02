//
//  ProductProfileView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.02.2024.
//

import SwiftUI
import CardGuardianModule

struct ProductProfileView: View {
    
    @ObservedObject var viewModel: ProductProfileViewModel
    
    @State var showingDetail = false
    
    var body: some View {
        
        openCardGuardinaButton()
    }
    
    private func openCardGuardinaButton() -> some View {
        
        Button(
            "Card Guardian",
            action: {
                //viewModel.openCardGuardian
                
                self.showingDetail.toggle()
            }
        )
        .sheet(isPresented: $showingDetail) {
            CardGuardianModule.ThreeButtonsWrappedView(
                viewModel: viewModel.openCardGuardian(),
                config: .preview)
            .padding(.top, 26)
            .padding(.bottom, 72)
        }
    }
}


#Preview {
    ProductProfileView(
        viewModel: .init(
            navigationStateManager: .init(makeCardGuardianViewModel: { _ in
                
                    .init(
                        initialState: .init(buttons: .preview),
                        reduce: {_,_ in
                            (CardGuardianState.init(buttons: .preview), .none)
                        },
                        handleEffect: {_,_ in }
                    )
            })))
}

