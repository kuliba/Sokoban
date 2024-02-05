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
        
        ProductProfileView(viewModel: .init(initialState: .init(), navigationStateManager: .init(
            reduce: { _, event, _ in
                
                /*switch event {
                    
                case .dismissDestination:
                    return                 (ProductProfileNavigation.State.init(
                        destination: .none,
                        alert: .init(title: "Alert", message: "test", primaryButton: .init(type: .cancel, title: "Ок", event: .dismissDestination)),
                        isLoading: true), .none)
                    
                default:*/
                    return (ProductProfileNavigation.State.init(), .none)
                //}
                
            },
            makeCardGuardianViewModel: { _ in
            
                .init(
                    initialState: .init(buttons: .preview),
                    reduce: { _,_ in
                        (CardGuardianState.init(buttons: .preview), .none)
                    },
                    handleEffect: { _,_ in }
                )
        })))
        .padding()
    }
}

#Preview {
    ContentView()
}
