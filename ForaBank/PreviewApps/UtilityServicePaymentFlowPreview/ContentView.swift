//
//  ContentView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = PaymentsTransfersViewModel(
        state: .init(
            route: .init(
                destination: .utilityPayment(.init(
                    viewModel: .preview()
                ))
            )
        ),
        factory: .preview,
        navigationStateManager: .preview(),
        rootActions: .preview
    )
    
    var body: some View {
        
        NavigationView {
            
            PaymentsTransfersView(viewModel: viewModel, config: .preview)
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
}
