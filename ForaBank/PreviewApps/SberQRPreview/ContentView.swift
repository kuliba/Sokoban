//
//  ContentView.swift
//  SberQRPreview
//
//  Created by Igor Malyarov on 16.11.2023.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject private var navigationModel: NavigationModel
    private let composer: Composer
    
    init(navigation: Navigation? = nil) {
        
        let composer = Composer(navigation: navigation)
        self.composer = composer
        self.navigationModel = composer.navigationModel
    }
    
    var body: some View {
        
        composer.makeMainView()
            .navigationDestination(
                item: .init(
                    get: { navigationModel.navigation?.destination },
                    set: { if $0 == nil { navigationModel.resetNavigation() }}
                ),
                content: composer.makeDestinationView
            )
            .fullScreenCover(
                item: .init(
                    get: { navigationModel.navigation?.fullScreenCover },
                    set: { if $0 == nil { navigationModel.resetNavigation() }}
                ),
                content: composer.makeFullScreenCoverView
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
