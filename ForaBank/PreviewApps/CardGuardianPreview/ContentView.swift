//
//  ContentView.swift
//  CardGuardianPreview
//
//  Created by Andryusina Nataly on 02.02.2024.
//

import SwiftUI
import CardGuardianModule

struct ContentView: View {
    
    var body: some View {
        
        ProductProfileView(viewModel: .init(navigationStateManager: .init(makeCardGuardianViewModel: { _ in
            
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
