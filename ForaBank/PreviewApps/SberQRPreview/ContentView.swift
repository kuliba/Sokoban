//
//  ContentView.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

struct ContentView<MainView, DestinationView, FullScreenCoverView>: View
where MainView: View,
      DestinationView: View,
      FullScreenCoverView: View{
    
    @ObservedObject var navigationModel: NavigationModel
    
    let mainView: () -> MainView
    let destinationView: (Navigation.Destination) -> DestinationView
    let fullScreenCoverView: (Navigation.FullScreenCover) -> FullScreenCoverView
    
    var body: some View {
        
        mainView()
            .navigationDestination(
                item: .init(
                    get: { navigationModel.navigation?.destination },
                    set: { if $0 == nil { navigationModel.resetNavigation() }}
                ),
                content: destinationView
            )
            .fullScreenCover(
                item: .init(
                    get: { navigationModel.navigation?.fullScreenCover },
                    set: { if $0 == nil { navigationModel.resetNavigation() }}
                ),
                content: fullScreenCoverView
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView(
            navigationModel: .init(),
            mainView: { Text("Main View") },
            destinationView: { _ in Text("Destination View") },
            fullScreenCoverView: { _ in Text("Full Screen Cover View") }
        )
    }
}
