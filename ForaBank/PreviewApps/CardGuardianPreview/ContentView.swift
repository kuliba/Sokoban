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
        CardGuardianModule.ThreeButtonsWrappedView(viewModel: .init(initialState: .init(buttons: .preview), reduce: {_,_ in
            (CardGuardianState.init(buttons: .preview), .none)
        }, handleEffect: {_,_ in }), config: .preview)
        .padding(.top, 26)
        .padding(.bottom, 72)        .padding()
    }
}

#Preview {
    ContentView()
}
