//
//  ContentView.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

struct ContentView<MainView: View, FullScreenCoverView: View>: View {
    
    @ObservedObject var navigationModel: NavigationModel
    let mainView: () -> MainView
    let fullScreenCoverView: (Navigation.FullScreenCover) -> FullScreenCoverView
    
    var body: some View {
        
        mainView()
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
            fullScreenCoverView: { _ in Text("Full Screen Cover View") }
        )
    }
}
