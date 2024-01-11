//
//  ContentView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        Button("Fast Payments Settings", action: viewModel.openFastPaymentsSettings)
            .navigationDestination(
                item: .init(
                    get: { viewModel.route.destination },
                    set: { if $0 == nil { viewModel.resetDestination() }}
                ),
                destination: destinationView
            )
    }
    
    private func destinationView(
        destination: ViewModel.Route.Destination
    ) -> some View {
        
        switch destination {
        case .fastPaymentsSettings:
            Text("TBD")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView(viewModel: .init())
    }
}
