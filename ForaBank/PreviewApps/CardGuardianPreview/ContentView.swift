//
//  ContentView.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 02.02.2024.
//

import SwiftUI
import CardGuardianModule
import ProductProfile

struct ContentView: View {
    
    var body: some View {
        
        TabView {
            
            ProductProfileView.cardUnblokedOnMain
                .tabItem {
                    Label("1", systemImage: "lock.open")
                }
            
            ProductProfileView.cardBlockedHideOnMain
                .tabItem {
                    Label("2", systemImage: "lock")
                }
        }
    }
}

#Preview {
    ContentView()
}

private extension ProductProfileViewModel.Product {
    
    static let cardUnblokedOnMain: Self = .init(isUnBlock: true, isShowOnMain: true)
    
    static let cardBlockedHideOnMain: Self = .init(isUnBlock: false, isShowOnMain: false)
}

private extension ProductProfileView {
    
    static let cardUnblokedOnMain: Self = .init(
        viewModel: .init(
            product: .cardUnblokedOnMain,
            initialState: .init(),
            navigationStateManager: .init(
                reduce: ProductProfileReducer().reduce(_:_:),
                makeCardGuardianViewModel: { _ in
                    
                        .init(
                            initialState: .init(buttons: .preview),
                            reduce: CardGuardianReducer().reduce(_:_:),
                            handleEffect: { _,_ in }
                        )
                })))
    
    static let cardBlockedHideOnMain : Self = .init(
        viewModel: .init(
            product: .cardBlockedHideOnMain,
            initialState: .init(),
            navigationStateManager: .init(
                reduce: ProductProfileReducer().reduce(_:_:),
                makeCardGuardianViewModel: { _ in
                    
                        .init(
                            initialState: .init(buttons: .previewBlockHide),
                            reduce: CardGuardianReducer().reduce(_:_:),
                            handleEffect: { _,_ in }
                        )
                })))
}
